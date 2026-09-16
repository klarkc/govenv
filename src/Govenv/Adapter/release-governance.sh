#!/usr/bin/env bash
set -euo pipefail

target="${GOVENV_RELEASE_TARGET:-pull-request}"
release_pr="${GOVENV_RELEASE_PR:-${1:-}}"
release_tag="${GOVENV_RELEASE_TAG:-}"
release_version="${GOVENV_RELEASE_VERSION:-}"
base_ref="${GOVENV_RELEASE_BASE_REF:-${2:-}}"
head_ref="${GOVENV_RELEASE_HEAD_REF:-${3:-}}"
head_ref_explicit=true
if [[ -z "${head_ref}" ]]; then
  head_ref="HEAD"
  head_ref_explicit=false
fi
release_heading="${GOVENV_RELEASE_HEADING:-}"
release_notes_file="${GOVENV_RELEASE_NOTES_FILE:-}"
release_notes=""
candidate_base_ref=""
candidate_authorized_revision=""

root="$(git rev-parse --show-toplevel)"
cd "${root}"

# Derived materializations are causally bound to their immediate Git parent.
# The parent edge is content-addressed by Git and survives rebase rewriting,
# unlike a copied SHA trailer from the pre-rebase candidate branch.
source src/Govenv/Adapter/revision-provenance.sh

load_candidate_boundary() {
  local document="$1"
  local version="$2"
  local marker_open marker_name version_field base_field authorized_field marker_close

  mapfile -t freeze_lines < <(
    grep -F "<!-- govenv-release-freeze: version=${version} " "${document}" || true
  )
  if [[ "${#freeze_lines[@]}" -ne 1 ]]; then
    echo "Release ${version} must have exactly one governed freeze boundary." >&2
    return 3
  fi

  read -r marker_open marker_name version_field base_field authorized_field marker_close <<< "${freeze_lines[0]}"
  candidate_base_ref="${base_field#base=}"
  candidate_authorized_revision="${authorized_field#authorized=}"
  if [[ "${marker_open}" != '<!--' || "${marker_name}" != 'govenv-release-freeze:' ||
        "${version_field}" != "version=${version}" || "${marker_close}" != '-->' ||
        ! "${candidate_base_ref}" =~ ^v[0-9]+\.[0-9]+\.[0-9]+([+-][0-9A-Za-z.-]+)?$ ||
        ! "${candidate_authorized_revision}" =~ ^[0-9a-f]{40}$ ]]; then
    echo "Release ${version} freeze boundary is malformed." >&2
    return 3
  fi
}

validate_candidate_boundary() {
  local expected_base="$1"
  local containing_revision="$2"
  local expected_version="${expected_base#v}"
  local authorized_manifest_version

  if [[ "${candidate_base_ref}" != "${expected_base}" ]]; then
    echo "Release freeze base ${candidate_base_ref} does not match expected base ${expected_base}." >&2
    return 3
  fi
  git rev-parse --verify "${candidate_authorized_revision}^{commit}" >/dev/null
  if ! git merge-base --is-ancestor "${candidate_authorized_revision}" "${containing_revision}"; then
    echo "Release freeze authority is not an ancestor of ${containing_revision}." >&2
    return 3
  fi
  authorized_manifest_version="$(
    git show "${candidate_authorized_revision}:.github/release-please/manifest.json" |
      jq -r '.["."] // empty'
  )"
  if [[ "${authorized_manifest_version}" != "${expected_version}" ]]; then
    echo "Release freeze authority is not based on ${expected_base}." >&2
    return 3
  fi
}

extract_candidate_notes() {
  local document="$1"
  local version="$2"

  awk -v version="${version}" '
    BEGIN { heading = "## [" version "]" }
    /^## \[/ {
      if (in_target) exit
      if (index($0, heading) == 1) { in_target = 1; next }
    }
    !in_target { next }
    /^<!-- govenv-release-freeze:/ { next }
    /<!-- govenv-governance-impact:start -->/ { governance = 1; next }
    governance && /<!-- govenv-governance-impact:end -->/ { governance = 0; next }
    governance { next }
    { lines[++count] = $0 }
    END {
      first = 1
      while (first <= count && lines[first] == "") first++
      last = count
      while (last >= first && lines[last] == "") last--
      for (i = first; i <= last; i++) print lines[i]
    }
  ' "${document}"
}

case "${target}" in
  pull-request)
    if [[ -z "${release_pr}" || ! "${release_pr}" =~ ^[0-9]+$ ]]; then
      echo "GOVENV_RELEASE_PR or the first argument must be a pull request number." >&2
      exit 2
    fi
    release_tag=""
    if [[ -z "${release_version}" ]]; then
      repository="$(gh repo view --json nameWithOwner --jq '.nameWithOwner')"
      release_head="$(gh pr view "${release_pr}" --json headRefName --jq '.headRefName')"
      release_version="$(
        gh api -H 'Accept: application/vnd.github.raw+json' --method GET \
          "repos/${repository}/contents/.github/release-please/manifest.json" \
          -f ref="${release_head}" | jq -r '.["."] // empty'
      )"
    fi
    if [[ "${head_ref_explicit}" == false ]]; then
      head_ref="$(resolve_causal_revision HEAD)"
    fi
    ;;
  changelog)
    release_pr="0"
    release_tag=""
    if [[ -z "${release_version}" ]]; then
      latest_tag="$(git describe --tags --abbrev=0 2>/dev/null || true)"
      if [[ -z "${latest_tag}" ]]; then
        echo "Canonical changelog materialization requires a published release tag." >&2
        exit 2
      fi
      latest_version="${latest_tag#v}"
      manifest_version="$(jq -r '.["."] // empty' .github/release-please/manifest.json)"
      if [[ -z "${manifest_version}" ]]; then
        echo "Release Please manifest has no root version." >&2
        exit 2
      fi

      if [[ "${manifest_version}" == "${latest_version}" ]]; then
        release_version="Unreleased"
        base_ref="${latest_tag}"
        if [[ "${head_ref_explicit}" == false ]]; then
          head_ref="$(resolve_causal_revision HEAD)"
        fi
      else
        release_version="${manifest_version}"
        load_candidate_boundary CHANGELOG.md "${release_version}"
        validate_candidate_boundary "${latest_tag}" HEAD
        base_ref="${candidate_base_ref}"
        head_ref="${candidate_authorized_revision}"
        release_heading="$(
          awk -v version="${release_version}" 'index($0, "## [" version "]") == 1 { print; exit }' CHANGELOG.md
        )"
        release_notes="$(extract_candidate_notes CHANGELOG.md "${release_version}")"
      fi
    fi
    ;;
  github-release)
    if [[ -z "${release_tag}" ]]; then
      echo "GOVENV_RELEASE_TAG is required for a GitHub Release materialization." >&2
      exit 2
    fi
    release_pr="0"
    if [[ -z "${release_version}" ]]; then
      release_version="${release_tag#v}"
    fi
    published_revision="${head_ref}"
    published_changelog="$(mktemp)"
    if ! git show "${published_revision}:CHANGELOG.md" > "${published_changelog}" 2>/dev/null; then
      rm -f "${published_changelog}"
      echo "Published release revision has no canonical changelog." >&2
      exit 3
    fi
    previous_tag="$(git describe --tags --abbrev=0 "${published_revision}^" 2>/dev/null || true)"
    if [[ -z "${previous_tag}" ]]; then
      rm -f "${published_changelog}"
      echo "Published release has no previous release boundary." >&2
      exit 3
    fi
    load_candidate_boundary "${published_changelog}" "${release_version}"
    validate_candidate_boundary "${previous_tag}" "${published_revision}"
    rm -f "${published_changelog}"
    base_ref="${candidate_base_ref}"
    head_ref="${candidate_authorized_revision}"
    ;;
  *)
    echo "Unsupported GOVENV_RELEASE_TARGET: ${target}" >&2
    exit 2
    ;;
esac

if [[ -z "${release_version}" ]]; then
  echo "Could not resolve a release document heading." >&2
  exit 2
fi
if [[ "${release_version}" != "Unreleased" ]] &&
   [[ ! "${release_version}" =~ ^[0-9]+\.[0-9]+\.[0-9]+([+-][0-9A-Za-z.-]+)?$ ]]; then
  echo "Could not resolve a safe Release Please version." >&2
  exit 2
fi
if [[ "${target}" != "changelog" && "${release_version}" == "Unreleased" ]]; then
  echo "Unreleased is valid only for canonical changelog materialization." >&2
  exit 2
fi

if [[ "${release_version}" == "Unreleased" ]]; then
  release_heading="## [Unreleased]"
  release_notes=""
else
  if [[ -z "${release_heading}" ]]; then
    release_heading="## [${release_version}]"
  fi
  if [[ "${release_heading}" != "## [${release_version}]"* ]]; then
    echo "Release heading does not match candidate version ${release_version}." >&2
    exit 2
  fi
  if [[ -n "${release_notes_file}" ]]; then
    if [[ ! -f "${release_notes_file}" ]]; then
      echo "Release notes observation does not exist: ${release_notes_file}" >&2
      exit 2
    fi
    release_notes="$(cat "${release_notes_file}")"
  fi
fi

if [[ -z "${base_ref}" ]]; then
  if [[ "${target}" == "github-release" ]]; then
    base_ref="$(git describe --tags --abbrev=0 "${head_ref}^" 2>/dev/null || true)"
  else
    base_ref="$(git describe --tags --abbrev=0 2>/dev/null || true)"
  fi
fi
if [[ -z "${base_ref}" ]]; then
  echo "A release base ref is required." >&2
  exit 2
fi

git rev-parse --verify "${base_ref}^{commit}" >/dev/null
git rev-parse --verify "${head_ref}^{commit}" >/dev/null

base_commit="$(git rev-parse "${base_ref}^{commit}")"
head_commit="$(git rev-parse "${head_ref}^{commit}")"
include_current_release=true
if [[ "${release_version}" == "Unreleased" && "${base_commit}" == "${head_commit}" ]]; then
  include_current_release=false
fi
if [[ "${release_version}" != "Unreleased" ]]; then
  candidate_base_ref="${candidate_base_ref:-${base_ref}}"
  candidate_authorized_revision="${candidate_authorized_revision:-${head_commit}}"
fi

input_root=".govenv/release-input"
input_dir="${input_root}/Govenv/Adapter"
build_dir=".govenv/release-governance-build"
mkdir -p "${input_dir}"
rm -rf "${build_dir}"
mkdir -p "${build_dir}"

previous_snapshot=".govenv/release-previous.snapshot"
if git show "${base_ref}:.govenv/roadmap.snapshot" > "${previous_snapshot}" 2>/dev/null; then
  first_line="$(sed -n '1p' "${previous_snapshot}")"
  if [[ "${first_line}" != "govenv-roadmap-snapshot-v2" ]]; then
    echo "Unsupported roadmap snapshot format at ${base_ref}." >&2
    exit 3
  fi
else
  # v0.1.0 predates governed roadmap snapshots. Treat it conservatively as
  # an absent historical roadmap; future releases must use the typed snapshot.
  printf '%s\n' 'govenv-roadmap-snapshot-v2' 'phase absent' > "${previous_snapshot}"
fi

phase_expr=""
item_exprs=()
while IFS= read -r line; do
  case "${line}" in
    govenv-roadmap-snapshot-v2) ;;
    "phase absent")
      [[ -z "${phase_expr}" ]] || { echo "Duplicate phase in snapshot." >&2; exit 3; }
      phase_expr="snapshotAbsent"
      ;;
    "phase active "*)
      value="${line#phase active }"
      [[ "${value}" =~ ^[0-9]+$ ]] || { echo "Invalid active phase: ${line}" >&2; exit 3; }
      [[ -z "${phase_expr}" ]] || { echo "Duplicate phase in snapshot." >&2; exit 3; }
      phase_expr="snapshotActive ${value}"
      ;;
    "phase complete "*)
      value="${line#phase complete }"
      [[ "${value}" =~ ^[0-9]+$ ]] || { echo "Invalid complete phase: ${line}" >&2; exit 3; }
      [[ -z "${phase_expr}" ]] || { echo "Duplicate phase in snapshot." >&2; exit 3; }
      phase_expr="snapshotComplete ${value}"
      ;;
    "item "*)
      if [[ "${line}" =~ ^item\ ([0-9]+)\ phase\ ([0-9]+)\ (done|todo|cancelled)\ (\".*\")$ ]]; then
        item_exprs+=("snapshotItem ${BASH_REMATCH[1]} ${BASH_REMATCH[2]} ${BASH_REMATCH[4]} ${BASH_REMATCH[3]}")
      elif [[ "${line}" =~ ^item\ ([0-9]+)\ phase\ ([0-9]+)\ superseded\ ([0-9]+)\ (\".*\")$ ]]; then
        item_exprs+=("snapshotItem ${BASH_REMATCH[1]} ${BASH_REMATCH[2]} ${BASH_REMATCH[4]} (superseded (GVR ${BASH_REMATCH[3]}))")
      else
        echo "Invalid roadmap snapshot item: ${line}" >&2
        exit 3
      fi
      ;;
    "") ;;
    *)
      echo "Invalid roadmap snapshot line: ${line}" >&2
      exit 3
      ;;
  esac
done < "${previous_snapshot}"

if [[ -z "${phase_expr}" ]]; then
  echo "Roadmap snapshot has no phase state." >&2
  exit 3
fi

references=()
while IFS= read -r value; do
  [[ -n "${value}" ]] && references+=("${value#GV}")
done < <(emit_governance_references "${base_ref}" "${head_ref}")

agda_list() {
  local expression="[]"
  local index
  for ((index=${#@}; index>0; index--)); do
    value="${!index}"
    expression="${value} ∷ (${expression})"
  done
  printf '%s' "${expression}"
}

extract_release_entry() {
  local document="$1"
  local version="$2"
  awk -v version="${version}" '
    BEGIN {
      bracket = "## [" version "]"
      plain = "## " version
    }
    /^## / {
      if (capture) exit
      if (index($0, bracket) == 1 || $0 == plain || index($0, plain " ") == 1) capture = 1
    }
    capture { print }
  ' "${document}"
}

historical_exprs=()
while IFS= read -r history_tag; do
  [[ -n "${history_tag}" ]] || continue
  history_version="${history_tag#v}"
  history_document="$(mktemp)"
  history_entry="$(mktemp)"
  if ! git show "${history_tag}:CHANGELOG.md" > "${history_document}" 2>/dev/null; then
    rm -f "${history_document}" "${history_entry}"
    echo "Published release ${history_tag} has no reconstructible CHANGELOG.md." >&2
    exit 3
  fi
  extract_release_entry "${history_document}" "${history_version}" > "${history_entry}"
  rm -f "${history_document}"
  if [[ ! -s "${history_entry}" ]]; then
    rm -f "${history_entry}"
    echo "Published release ${history_tag} has no reconstructible changelog entry." >&2
    exit 3
  fi
  historical_exprs+=("$(jq -Rs . < "${history_entry}")")
  rm -f "${history_entry}"
done < <(git tag --merged "${base_ref}" --list 'v[0-9]*' --sort=-v:refname)

historical_entries_expr="$(agda_list "${historical_exprs[@]}")"
release_heading_expr="$(printf '%s' "${release_heading}" | jq -Rs .)"
release_notes_expr="$(printf '%s' "${release_notes}" | jq -Rs .)"
candidate_base_ref_expr="$(printf '%s' "${candidate_base_ref}" | jq -Rs .)"
candidate_authorized_revision_expr="$(printf '%s' "${candidate_authorized_revision}" | jq -Rs .)"
if [[ "${release_version}" == "Unreleased" ]]; then
  candidate_version_expr="nothing"
else
  candidate_version_expr="just \"${release_version}\""
fi

items_expr="$(agda_list "${item_exprs[@]}")"
reference_exprs=()
for value in "${references[@]}"; do
  reference_exprs+=("${value}")
done
references_expr="$(agda_list "${reference_exprs[@]}")"
base_revision="$(git rev-parse --short=7 "${base_ref}")"
head_revision="$(git rev-parse --short=7 "${head_ref}")"
observation="${input_dir}/ReleaseObservation.agda"

cat > "${observation}" <<EOF
{-# OPTIONS --safe #-}
module Govenv.Adapter.ReleaseObservation where

open import Agda.Builtin.Bool using (Bool; true; false)
open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.Maybe using (Maybe; just; nothing)
open import Agda.Builtin.Nat using (Nat)
open import Agda.Builtin.String using (String)
open import Govenv.Kernel.Identifier using (GVR)
open import Govenv.Kernel.Release
open import Govenv.Kernel.Roadmap using (done; todo; cancelled; superseded)

previous : RoadmapSnapshot
previous = roadmapSnapshot (${phase_expr}) (${items_expr})

references : List Nat
references = ${references_expr}

releasePullRequest : Nat
releasePullRequest = ${release_pr}

releaseVersion : String
releaseVersion = "${release_version}"

candidateVersion : Maybe String
candidateVersion = ${candidate_version_expr}

includeCurrentRelease : Bool
includeCurrentRelease = ${include_current_release}

candidateBaseRef : String
candidateBaseRef = ${candidate_base_ref_expr}

candidateAuthorizedRevision : String
candidateAuthorizedRevision = ${candidate_authorized_revision_expr}

releaseHeading : String
releaseHeading = ${release_heading_expr}

releaseNotes : String
releaseNotes = ${release_notes_expr}

historicalEntries : List String
historicalEntries = ${historical_entries_expr}

baseRevision : String
baseRevision = "${base_revision}"

headRevision : String
headRevision = "${head_revision}"

releaseTag : String
releaseTag = "${release_tag}"
EOF

compile_agda() {
  local adapter="$1"
  if command -v agda >/dev/null 2>&1; then
    agda -i "${input_root}" -i . -i src --compile \
      --compile-dir="${build_dir}" "${adapter}" >/dev/null
  else
    nix run github:cachix/devenv/v2.3 -- shell -- \
      agda -i "${input_root}" -i . -i src --compile \
      --compile-dir="${build_dir}" "${adapter}" >/dev/null
  fi
}

if [[ "${target}" == "pull-request" ]]; then
  compile_agda src/Govenv/Adapter/ReleaseGovernance/Body.agda
  compile_agda src/Govenv/Adapter/ReleaseGovernance/Changelog.agda

  body_output=".govenv/release-governance-body.md"
  changelog_output=".govenv/release-governance-changelog.md"
  "${build_dir}/Body" > "${body_output}"
  "${build_dir}/Changelog" > "${changelog_output}"
  cat "${body_output}"
elif [[ "${target}" == "changelog" ]]; then
  compile_agda src/Govenv/Adapter/ReleaseGovernance/Changelog.agda

  changelog_output=".govenv/release-governance-changelog.md"
  "${build_dir}/Changelog" > "${changelog_output}"
  cat "${changelog_output}"
else
  compile_agda src/Govenv/Adapter/ReleaseGovernance/Release.agda

  release_output=".govenv/release-governance-release.md"
  "${build_dir}/Release" > "${release_output}"
  cat "${release_output}"
fi
