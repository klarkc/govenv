#!/usr/bin/env python3
import argparse
import json
import os
import re
import subprocess
import sys
import threading
from urllib.parse import unquote, urlparse

documents = {}
backend_diagnostics = {}
client_write_lock = threading.Lock()
initialize_ids = set()


def read_message(stream):
    headers = {}
    while True:
        line = stream.readline()
        if not line:
            return None
        if line in (b"\r\n", b"\n"):
            break
        key, value = line.decode("ascii").split(":", 1)
        headers[key.lower()] = value.strip()
    length = int(headers["content-length"])
    return json.loads(stream.read(length))

def write_message(stream, message, lock=None):
    body = json.dumps(message, separators=(",", ":")).encode()
    payload = f"Content-Length: {len(body)}\r\n\r\n".encode() + body
    if lock is None:
        stream.write(payload)
        stream.flush()
        return
    with lock:
        stream.write(payload)
        stream.flush()


def uri_path(uri):
    parsed = urlparse(uri)
    if parsed.scheme != "file":
        return ""
    return unquote(parsed.path)


def utf16_units(text):
    return len(text.encode("utf-16-le")) // 2


def utf16_index(line, units):
    used = 0
    for index, char in enumerate(line):
        width = utf16_units(char)
        if used + width > units:
            return index
        used += width
    return len(line)

def position_to_offset(text, position):
    lines = text.splitlines(keepends=True)
    target = position["line"]
    if target >= len(lines):
        return len(text)
    prefix = sum(len(line) for line in lines[:target])
    line = lines[target]
    bare = line.rstrip("\r\n")
    return prefix + utf16_index(bare, position["character"])


def apply_changes(text, changes):
    for change in changes:
        if "range" not in change:
            text = change["text"]
            continue
        start = position_to_offset(text, change["range"]["start"])
        end = position_to_offset(text, change["range"]["end"])
        text = text[:start] + change["text"] + text[end:]
    return text


def agda_line_mask(path, lines):
    if not path.endswith(".lagda.md"):
        return [True] * len(lines)
    ticks = chr(96) * 3
    mask = []
    in_agda = False
    for line in lines:
        stripped = line.strip()
        if stripped == "~~~agda" or stripped == ticks + "agda":
            in_agda = True
            mask.append(False)
            continue
        if in_agda and stripped in ("~~~", ticks):
            in_agda = False
            mask.append(False)
            continue
        mask.append(in_agda)
    return mask

def diagnostic(line, start, end, severity, code, message):
    return {
        "range": {
            "start": {"line": line, "character": start},
            "end": {"line": line, "character": end},
        },
        "severity": severity,
        "source": "govenv-agda-style",
        "code": code,
        "message": message,
    }


def lint_document(uri, text):
    path = uri_path(uri)
    lines = text.splitlines()
    mask = agda_line_mask(path, lines)
    result = []

    for number, line in enumerate(lines):
        if number >= len(mask) or not mask[number]:
            continue
        if len(line) > 72:
            result.append(diagnostic(
                number, 72, len(line), 2, "stdlib-line-length-72",
                "Agda stdlib style guide recommends at most 72 columns.",
            ))
        for char in ("⦃", "⦄"):
            if char in line:
                column = line.index(char)
                result.append(diagnostic(
                    number, column, column + 1, 1,
                    "stdlib-no-unicode-instance-braces",
                    "Prefer ASCII {{_}} instance syntax.",
                ))

        if re.match(r"^\s*mutual(?:\s|$)", line):
            result.append(diagnostic(
                number, 0, len(line), 1, "stdlib-no-mutual-block",
                "The stdlib style guide treats mutual blocks as obsolete.",
            ))

    governed_literate = "/Govenv/" in path and path.endswith(".lagda.md")
    kernel_source = "/src/Govenv/Kernel/" in path and path.endswith(".agda")
    if (governed_literate or kernel_source) and "{-# OPTIONS --safe #-}" not in text:
        result.append(diagnostic(
            0, 0, 1, 1, "govenv-safe-formal-source",
            "Govenv governed formal source and reusable kernel source require --safe.",
        ))
    if kernel_source:
        for number, line in enumerate(lines):
            if re.match(r"^\s*postulate(?:\s|$)", line):
                result.append(diagnostic(
                    number, 0, len(line), 1, "govenv-no-kernel-postulate",
                    "Reusable Govenv kernel source must remain free of postulate.",
                ))
    return result


def format_document(uri, text):
    path = uri_path(uri)
    lines = text.splitlines()
    mask = agda_line_mask(path, lines)
    formatted = []
    for number, line in enumerate(lines):
        if number < len(mask) and mask[number]:
            line = line.rstrip(" \t")
        formatted.append(line)
    return "\n".join(formatted) + "\n"

def full_document_edit(original, replacement):
    lines = original.split("\n")
    end = {
        "line": len(lines) - 1,
        "character": utf16_units(lines[-1]),
    }
    return {
        "range": {
            "start": {"line": 0, "character": 0},
            "end": end,
        },
        "newText": replacement,
    }


def publish_diagnostics(uri, text):
    diagnostics = backend_diagnostics.get(uri, []) + lint_document(uri, text)
    message = {
        "jsonrpc": "2.0",
        "method": "textDocument/publishDiagnostics",
        "params": {"uri": uri, "diagnostics": diagnostics},
    }
    write_message(sys.stdout.buffer, message, client_write_lock)


def backend_reader(process):
    while True:
        message = read_message(process.stdout)
        if message is None:
            return
        identifier = message.get("id")
        if identifier in initialize_ids and "result" in message:
            capabilities = message["result"].setdefault("capabilities", {})
            capabilities["documentFormattingProvider"] = True
            initialize_ids.discard(identifier)
        if message.get("method") == "textDocument/publishDiagnostics":
            params = message.get("params", {})
            uri = params.get("uri", "")
            backend_diagnostics[uri] = params.get("diagnostics", [])
            params["diagnostics"] = (
                backend_diagnostics[uri]
                + lint_document(uri, documents.get(uri, ""))
            )
        write_message(sys.stdout.buffer, message, client_write_lock)

def handle_client_message(process, message):
    method = message.get("method")
    params = message.get("params", {})

    if method == "initialize":
        initialize_ids.add(message.get("id"))

    if method == "textDocument/didOpen":
        document = params["textDocument"]
        documents[document["uri"]] = document["text"]
        write_message(process.stdin, message)
        publish_diagnostics(document["uri"], document["text"])
        return

    if method == "textDocument/didChange":
        document = params["textDocument"]
        uri = document["uri"]
        text = apply_changes(documents.get(uri, ""), params.get("contentChanges", []))
        documents[uri] = text
        write_message(process.stdin, message)
        publish_diagnostics(uri, text)
        return

    if method == "textDocument/didSave":
        uri = params["textDocument"]["uri"]
        if "text" in params:
            documents[uri] = params["text"]
        write_message(process.stdin, message)
        publish_diagnostics(uri, documents.get(uri, ""))
        return

    if method == "textDocument/didClose":
        uri = params["textDocument"]["uri"]
        documents.pop(uri, None)
        backend_diagnostics.pop(uri, None)
        write_message(process.stdin, message)
        return

    if method == "textDocument/formatting":
        identifier = message["id"]
        uri = params["textDocument"]["uri"]
        current = documents.get(uri, "")
        formatted = format_document(uri, current)
        edits = (
            [] if formatted == current
            else [full_document_edit(current, formatted)]
        )
        response = {"jsonrpc": "2.0", "id": identifier, "result": edits}
        write_message(sys.stdout.buffer, response, client_write_lock)
        return

    write_message(process.stdin, message)


def main():
    parser = argparse.ArgumentParser(add_help=False)
    parser.add_argument("--backend", required=True)
    args, passthrough = parser.parse_known_args()

    if passthrough:
        os.execv(args.backend, [args.backend, *passthrough])

    process = subprocess.Popen(
        [args.backend],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=sys.stderr,
    )
    reader = threading.Thread(target=backend_reader, args=(process,), daemon=True)
    reader.start()

    try:
        while True:
            message = read_message(sys.stdin.buffer)
            if message is None:
                break
            handle_client_message(process, message)
    finally:
        if process.stdin:
            process.stdin.close()
        process.terminate()
        process.wait(timeout=5)


if __name__ == "__main__":
    main()
