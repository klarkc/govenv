#!/usr/bin/env python3
import json
import select
import subprocess
import sys
import time


def write_message(stream, message):
    body = json.dumps(message, separators=(",", ":")).encode()
    stream.write(f"Content-Length: {len(body)}\r\n\r\n".encode() + body)
    stream.flush()


def read_message(stream, timeout=8):
    ready, _, _ = select.select([stream], [], [], timeout)
    if not ready:
        raise TimeoutError("timed out waiting for LSP message")
    headers = {}
    while True:
        line = stream.readline()
        if line in (b"\r\n", b"\n"):
            break
        if not line:
            raise EOFError("LSP server closed output")
        key, value = line.decode("ascii").split(":", 1)
        headers[key.lower()] = value.strip()
    return json.loads(stream.read(int(headers["content-length"])))

def wait_for(stream, predicate):
    deadline = time.monotonic() + 12
    seen = []
    while time.monotonic() < deadline:
        message = read_message(stream, max(0.1, deadline - time.monotonic()))
        seen.append(message)
        if predicate(message):
            return message, seen
    raise AssertionError(f"message not observed: {seen!r}")


def main():
    executable = sys.argv[1]
    process = subprocess.Popen(
        [executable],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
    )
    uri = "file:///tmp/GovenvStyleProbe.agda"
    sample = (
        "{-# OPTIONS --safe #-}\n"
        "module GovenvStyleProbe where  \n"
        + "x = " + "a" * 80 + "\n"
        + "instanceValue : {{A : Set}} -> Set\n"
        + "instanceValue {{A}} = A\n"
    )

    try:
        write_message(process.stdin, {
            "jsonrpc": "2.0", "id": 1, "method": "initialize",
            "params": {"processId": None, "rootUri": "file:///tmp", "capabilities": {}},
        })
        initialized, _ = wait_for(
            process.stdout,
            lambda m: m.get("id") == 1 and "result" in m,
        )
        capabilities = initialized["result"]["capabilities"]
        assert capabilities.get("documentFormattingProvider") is True

        write_message(process.stdin, {
            "jsonrpc": "2.0", "method": "initialized", "params": {}
        })
        write_message(process.stdin, {
            "jsonrpc": "2.0", "method": "textDocument/didOpen",
            "params": {"textDocument": {
                "uri": uri, "languageId": "agda", "version": 1, "text": sample
            }},
        })
        diagnostics, _ = wait_for(
            process.stdout,
            lambda m: (
                m.get("method") == "textDocument/publishDiagnostics"
                and m.get("params", {}).get("uri") == uri
                and any(
                    d.get("source") == "govenv-agda-style"
                    for d in m.get("params", {}).get("diagnostics", [])
                )
            ),
        )

        codes = {
            d.get("code") for d in diagnostics["params"]["diagnostics"]
            if d.get("source") == "govenv-agda-style"
        }
        assert "stdlib-line-length-72" in codes

        write_message(process.stdin, {
            "jsonrpc": "2.0", "id": 2, "method": "textDocument/formatting",
            "params": {
                "textDocument": {"uri": uri},
                "options": {"tabSize": 2, "insertSpaces": True},
            },
        })
        formatted, _ = wait_for(
            process.stdout,
            lambda m: m.get("id") == 2,
        )
        edits = formatted["result"]
        assert len(edits) == 1
        output = edits[0]["newText"]
        assert "where  \n" not in output
        assert output.endswith("\n")

        write_message(process.stdin, {
            "jsonrpc": "2.0", "method": "textDocument/didChange",
            "params": {
                "textDocument": {"uri": uri, "version": 2},
                "contentChanges": [{"text": output}],
            },
        })
        write_message(process.stdin, {
            "jsonrpc": "2.0", "id": 3, "method": "textDocument/formatting",
            "params": {
                "textDocument": {"uri": uri},
                "options": {"tabSize": 2, "insertSpaces": True},
            },
        })
        second, _ = wait_for(process.stdout, lambda m: m.get("id") == 3)
        assert second["result"] == []

        print("govenv-agda-style-lsp-v1 ok")
    finally:
        process.terminate()
        process.wait(timeout=5)


if __name__ == "__main__":
    main()
