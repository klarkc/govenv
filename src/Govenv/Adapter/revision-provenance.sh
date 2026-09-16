#!/usr/bin/env bash
set -euo pipefail

materialization_subject='chore(materialize): update governed materializations'

is_derived_materialization_commit() {
  local revision="$1"
  local message

  if [[ "$(git show -s --format=%s "${revision}")" != "${materialization_subject}" ]]; then
    return 1
  fi

  message="$(git show -s --format=%B "${revision}")"
  printf '%s\n' "${message}" |
    grep -Eq '^Derived-From-Parent: true$|^Derived-From-(Authorized-)?Revision: [0-9a-f]{40}$'
}

resolve_causal_revision() {
  local revision="$1"
  local commit
  local -a lineage

  commit="$(git rev-parse "${revision}^{commit}")"
  while is_derived_materialization_commit "${commit}"; do
    read -r -a lineage <<< "$(git rev-list --parents -n 1 "${commit}")"
    if [[ "${#lineage[@]}" -ne 2 ]]; then
      echo "Derived materialization must have exactly one causal parent: ${commit}." >&2
      return 3
    fi
    commit="${lineage[1]}"
  done

  printf '%s\n' "${commit}"
}

emit_governance_references() {
  local base_ref="$1"
  local head_ref="$2"
  local commit

  while IFS= read -r commit; do
    if is_derived_materialization_commit "${commit}"; then
      continue
    fi
    git show -s --format=%B "${commit}"
  done < <(git rev-list --reverse "${base_ref}..${head_ref}") |
    awk '
      /^Refs:/ {
        line = $0
        while (match(line, /GV[0-9]+/)) {
          print substr(line, RSTART, RLENGTH)
          line = substr(line, RSTART + RLENGTH)
        }
      }
    ' |
    sort -uV
}
