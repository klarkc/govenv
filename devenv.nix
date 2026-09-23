{ pkgs, ... }:

let
  agdaStdlib = pkgs.agdaPackages.standard-library;

  buildMaterializers = ''
    rm -rf .govenv/materialize-build
    mkdir -p .govenv/materialize-build
    agda -i . -i src --compile --compile-dir=.govenv/materialize-build src/Govenv/Adapter/Readme.agda >/dev/null
    agda -i . -i src --compile --compile-dir=.govenv/materialize-build src/Govenv/Adapter/Agents.agda >/dev/null
    agda -i . -i src --compile --compile-dir=.govenv/materialize-build src/Govenv/Adapter/RoadmapSnapshot.agda >/dev/null
    agda -i . -i src --compile --compile-dir=.govenv/materialize-build src/Govenv/Adapter/Github/Workflows/Materialize.agda >/dev/null
    agda -i . -i src --compile --compile-dir=.govenv/materialize-build src/Govenv/Adapter/Github/Workflows/AdminMaterialize.agda >/dev/null
    agda -i . -i src --compile --compile-dir=.govenv/materialize-build src/Govenv/Adapter/Github/Workflows/Test.agda >/dev/null
    agda -i . -i src --compile --compile-dir=.govenv/materialize-build src/Govenv/Adapter/Github/Workflows/Release.agda >/dev/null
    agda -i . -i src --compile --compile-dir=.govenv/materialize-build src/Govenv/Adapter/Github/Workflows/Pages.agda >/dev/null
  '';

  checkRepositoryMetadataAdapter = ''
    agda -i . -i src src/Govenv/Adapter/Github/Repository/MetadataApplication.agda
  '';

  buildRepositoryMetadataAdapter = ''
    rm -rf .govenv/repository-metadata-build
    mkdir -p .govenv/repository-metadata-build
    agda -i . -i src --compile --compile-dir=.govenv/repository-metadata-build src/Govenv/Adapter/Github/Repository/MetadataApplication.agda >/dev/null
  '';

  checkAdminAdapters = ''
    agda -i . -i src src/Govenv/Adapter/Github/Actions/AdminEnvironment.agda
    agda -i . -i src src/Govenv/Adapter/Github/Actions/MaterializerEnvironmentBoundary.agda
    agda -i . -i src src/Govenv/Adapter/Github/Repository/MaterializerCredential.agda
    agda -i . -i src src/Govenv/Adapter/Github/Actions/MaterializerEnvironment.agda
    agda -i . -i src src/Govenv/Adapter/Github/Actions/AuthorizedEffectsEnvironment.agda
    agda -i . -i src src/Govenv/Adapter/Github/Actions/PagesEnvironment.agda
    agda -i . -i src src/Govenv/Adapter/Github/Repository/MainAuthorization.agda
    agda -i . -i src src/Govenv/Adapter/Github/Repository/MainAuthorityBoundary.agda
    agda -i . -i src src/Govenv/Adapter/Github/Repository/MainIntegrity.agda
    agda -i . -i src src/Govenv/Adapter/Github/Administration/Setup.agda
  '';

  buildAdminAdapters = ''
    rm -rf .govenv/admin-apply-build
    mkdir -p .govenv/admin-apply-build
    agda -i . -i src --compile --compile-dir=.govenv/admin-apply-build src/Govenv/Adapter/Github/Actions/AdminEnvironment.agda >/dev/null
    agda -i . -i src --compile --compile-dir=.govenv/admin-apply-build src/Govenv/Adapter/Github/Actions/MaterializerEnvironmentBoundary.agda >/dev/null
    agda -i . -i src --compile --compile-dir=.govenv/admin-apply-build src/Govenv/Adapter/Github/Repository/MaterializerCredential.agda >/dev/null
    agda -i . -i src --compile --compile-dir=.govenv/admin-apply-build src/Govenv/Adapter/Github/Actions/MaterializerEnvironment.agda >/dev/null
    agda -i . -i src --compile --compile-dir=.govenv/admin-apply-build src/Govenv/Adapter/Github/Actions/AuthorizedEffectsEnvironment.agda >/dev/null
    agda -i . -i src --compile --compile-dir=.govenv/admin-apply-build src/Govenv/Adapter/Github/Actions/PagesEnvironment.agda >/dev/null
    agda -i . -i src --compile --compile-dir=.govenv/admin-apply-build src/Govenv/Adapter/Github/Repository/MainAuthorization.agda >/dev/null
    agda -i . -i src --compile --compile-dir=.govenv/admin-apply-build src/Govenv/Adapter/Github/Repository/MainAuthorityBoundary.agda >/dev/null
    agda -i . -i src --compile --compile-dir=.govenv/admin-apply-build src/Govenv/Adapter/Github/Repository/MainIntegrity.agda >/dev/null
    agda -i . -i src --compile --compile-dir=.govenv/admin-apply-build src/Govenv/Adapter/Github/Administration/Setup.agda >/dev/null
  '';

  validateRoadmapEvolution = ''
    bash src/Govenv/Adapter/roadmap-evolution.sh
  '';

  materializeChangelog = output: ''
    changelog_tmp="${output}.tmp.$$"
    trap 'rm -f "$changelog_tmp"' EXIT
    if ! GOVENV_RELEASE_TARGET=changelog \
      bash src/Govenv/Adapter/release-governance.sh > "$changelog_tmp"; then
      exit 1
    fi
    mv "$changelog_tmp" ${output}
    trap - EXIT
  '';

  validateReleasePlacementRegression = ''
    GOVENV_RELEASE_PLACEMENT_COUNTEREXAMPLE=Govenv/Materialization/ReleaseGovernance/placement-counterexample.md \
      bash src/Govenv/Adapter/release-governance-pr.sh >/dev/null
  '';

  validateReleaseHistoryRegression = ''
    GOVENV_RELEASE_HISTORY_COUNTEREXAMPLE=Govenv/Materialization/ReleaseGovernance/history-preservation-counterexample.md \
      bash src/Govenv/Adapter/release-governance-pr.sh >/dev/null
  '';

  validateReleaseRebaseProvenanceRegression = ''
    GOVENV_RELEASE_REBASE_PROVENANCE_COUNTEREXAMPLE=Govenv/Materialization/ReleaseGovernance/rebase-provenance-counterexample.md \
      bash src/Govenv/Adapter/release-governance-pr.sh >/dev/null
  '';

  validatePagesHistoryRegression = ''
    fixture=Govenv/Materialization/Github/Workflows/pages-history-counterexample.md
    grep -Fq 'Materialize run #41' "$fixture"
    grep -Fq 'Canonical changelog materialization requires a published release tag.' "$fixture"
    if ! awk '
      /- name: "Checkout"/ { checkout = 1; next }
      checkout && /- name:/ { exit }
      checkout && /fetch-depth: "0"/ { found = 1 }
      END { exit found ? 0 : 1 }
    ' .govenv/pages.generated.yml; then
      echo 'Pages checkout must fetch full Git history before govenv:check.' >&2
      exit 5
    fi
  '';

  validateReleaseCandidateValidationRegression = ''
    fixture=Govenv/Materialization/ReleaseGovernance/candidate-validation-counterexample.md
    grep -Fq 'Materialize run #43' "$fixture"
    grep -Fq 'ec9ce3e24f74aab6b29eb168b13def6019f74969' "$fixture"
    grep -Fq "no checks reported on the 'release-please--branches--main--components--govenv' branch" "$fixture"
    grep -Fq 'Resolve release candidate revision' .govenv/release.generated.yml
    grep -Fq 'steps.candidate.outputs.sha' .govenv/release.generated.yml
    candidate_job="$(awk '
      /^  candidate-test:/ { capture = 1 }
      capture && /^  [^ ]+:/ && $0 !~ /^  candidate-test:/ { exit }
      capture { print }
    ' .govenv/release.generated.yml)"
    printf '%s\n' "$candidate_job" | grep -Fq 'needs: release-please'
    printf '%s\n' "$candidate_job" | grep -Fq 'contents: read'
    printf '%s\n' "$candidate_job" | grep -Fq 'uses: ./.github/workflows/test.yml'
    printf '%s\n' "$candidate_job" | grep -Fq 'needs.release-please.outputs.candidate-revision'
    if printf '%s\n' "$candidate_job" | grep -Eq 'contents: write|pull-requests: write|issues: write|environment:'; then
      echo 'Release candidate validation must remain unprivileged and read-only.' >&2
      exit 5
    fi
  '';

  validateTestExplicitRevisionRegression = ''
    fixture=Govenv/Materialization/Github/Workflows/test-revision-counterexample.md
    grep -Fq 'Materialize run #45' "$fixture"
    grep -Fq 'revision: 4e35ba5e9fc29414c3aa495b94ca76683793d5b9' "$fixture"
    grep -Fq 'ref: 1d8350e0891b6f9685f52063386475b03255d4d5' "$fixture"
    grep -Fq 'inputs.revision !=' .govenv/test.generated.yml
    grep -Fq '&& inputs.revision || github.event_name' .govenv/test.generated.yml
    if grep -Fq "github.event_name == 'workflow_call' && inputs.revision" .govenv/test.generated.yml; then
      echo 'Reusable Test revision must not depend on the inherited event name.' >&2
      exit 5
    fi
  '';

  validateReleasePostMergeFreezeRegression = ''
    fixture=Govenv/Materialization/ReleaseGovernance/post-merge-freeze-counterexample.md
    grep -Fq 'Materialize run #48' "$fixture"
    grep -Fq 'e76acb119c6514e93ef90312f1c956f308a42a42' "$fixture"
    grep -Fq 'Release 0.2.2 must have exactly one governed freeze boundary.' "$fixture"
    changelog_materializer="$(awk '
      /materializeChangelog = output:/ { capture = 1 }
      capture { print }
      capture && /trap - EXIT/ { exit }
    ' devenv.nix)"
    printf '%s\n' "$changelog_materializer" | grep -Fq 'changelog_tmp='
    printf '%s\n' "$changelog_materializer" | grep -Fq 'mv "$changelog_tmp"'
    if printf '%s\n' "$changelog_materializer" | grep -Eq 'release-governance\.sh[[:space:]]*>[[:space:]]*.*output'; then
      echo 'Canonical changelog materialization must not truncate its governed input before read-back.' >&2
      exit 5
    fi
  '';

  validateReleasePostPublicationConvergenceRegression = ''
    fixture=Govenv/Materialization/ReleaseGovernance/post-publication-unreleased-counterexample.md
    grep -Fq 'Materialize run #49' "$fixture"
    grep -Fq 'e76acb119c6514e93ef90312f1c956f308a42a42' "$fixture"
    grep -Fq '8dddae741144a242a4a5211cc5d44a1c2cfb338c' "$fixture"
    grep -Fq 'e76acb1..8dddae7' "$fixture"
    grep -Fq 'release-boundary:' .govenv/materialize.generated.yml
    grep -Fq 'steps.release-boundary.outputs.tag' .govenv/materialize.generated.yml
    grep -Fq 'Record release boundary' .govenv/materialize.generated.yml

    post_release_job="$(awk '
      /^  post-release-materialize:/ { capture = 1 }
      capture && /^  [^ ]+:/ && $0 !~ /^  post-release-materialize:/ { exit }
      capture { print }
    ' .govenv/materialize.generated.yml)"
    printf '%s\n' "$post_release_job" | grep -Fq 'needs: [materialize, release]'
    printf '%s\n' "$post_release_job" | grep -Fq "needs.release.result == 'success'"
    if printf '%s\n' "$post_release_job" | grep -Fq 'always()'; then
      echo 'Post-release materialization must not advance an unverified release boundary.' >&2
      exit 5
    fi
    printf '%s\n' "$post_release_job" | grep -Fq 'environment: "authorized-materialization"'
    printf '%s\n' "$post_release_job" | grep -Fq 'contents: read'
    printf '%s\n' "$post_release_job" | grep -Fq 'needs.materialize.outputs.effective-sha'
    printf '%s\n' "$post_release_job" | grep -Fq 'needs.materialize.outputs.release-boundary'
    printf '%s\n' "$post_release_job" | grep -Fq "steps.boundary.outputs.advanced == 'true'"
    printf '%s\n' "$post_release_job" | grep -Fq 'secrets.GOVENV_MATERIALIZER_SSH_KEY'
    if printf '%s\n' "$post_release_job" | grep -Eq 'contents: write|pull-requests: write|issues: write|actions: write'; then
      echo 'Post-release materialization must retain the read-only workflow token boundary.' >&2
      exit 5
    fi

    reconcile_job="$(awk '
      /^  release-reconcile:/ { capture = 1 }
      capture && /^  [^ ]+:/ && $0 !~ /^  release-reconcile:/ { exit }
      capture { print }
    ' .govenv/materialize.generated.yml)"
    printf '%s\n' "$reconcile_job" | grep -Fq 'needs: post-release-materialize'
    printf '%s\n' "$reconcile_job" | grep -Fq 'needs.post-release-materialize.outputs.changed'
    printf '%s\n' "$reconcile_job" | grep -Fq 'uses: ./.github/workflows/release.yml'
    printf '%s\n' "$reconcile_job" | grep -Fq 'needs.post-release-materialize.outputs.effective-sha'
    if printf '%s\n' "$reconcile_job" | grep -Fq 'actions: write'; then
      echo 'Release reconciliation must not gain generic Actions write authority.' >&2
      exit 5
    fi
  '';

  validateReleasePublishedRendererRegression = ''
    fixture=Govenv/Materialization/ReleaseGovernance/published-renderer-counterexample.md
    grep -Fq '35256420319' "$fixture"
    grep -Fq '<sub>Derived from immutable typed roadmap snapshots' "$fixture"
    grep -Fq 'portable canonical release entry' "$fixture"

    if grep -Fq 'renderGithubReleaseMaterialization' \
      src/Govenv/Adapter/ReleaseGovernance/Release.agda; then
      echo 'Published release verification must not use an independent GitHub renderer.' >&2
      exit 5
    fi
    grep -Fq 'renderPortableReleaseMaterialization' \
      src/Govenv/Adapter/ReleaseGovernance/Release.agda

    regression_tmp="$(mktemp -d)"
    trap 'rm -rf "$regression_tmp"' EXIT
    published_changelog="$regression_tmp/published.changelog.md"
    expected="$regression_tmp/published.expected.md"
    canonical="$regression_tmp/published.canonical.md"

    git show v0.2.4:CHANGELOG.md > "$published_changelog"

    for source in "$published_changelog" CHANGELOG.md; do
      output="$canonical"
      if [[ "$source" == "$published_changelog" ]]; then
        output="$expected"
      fi
      awk '
        /^## \[0\.2\.4\]/ { in_target = 1; next }
        in_target && /<!-- govenv-governance-impact:start -->/ { capture = 1 }
        in_target && capture { print }
        in_target && capture && /<!-- govenv-governance-impact:end -->/ { exit }
      ' "$source" > "$output"
    done

    if ! cmp -s "$expected" "$canonical"; then
      echo 'Published historical release governance must remain byte-identical to its immutable release boundary.' >&2
      diff -u "$expected" "$canonical" >&2 || true
      exit 5
    fi
    if grep -Fq '<sub>Derived from immutable typed roadmap snapshots' "$canonical"; then
      echo 'Published historical release governance must retain the portable canonical renderer.' >&2
      exit 5
    fi
    rm -rf "$regression_tmp"
    trap - EXIT
  '';

  validateReleasePublishedBodyReadbackRegression = ''
    fixture=Govenv/Materialization/ReleaseGovernance/published-body-readback-counterexample.md
    grep -Fq '35512667953' "$fixture"
    grep -Fq 'GitHub Release whole-body read-back verification failed.' "$fixture"
    grep -Fq 'terminal newline' "$fixture"

    grep -Fq "jq -j '.body // \"\"'" \
      src/Govenv/Adapter/release-governance-release.sh
    if grep -Fq -- "--jq '.body // \"\"'" \
      src/Govenv/Adapter/release-governance-release.sh; then
      echo 'Published release read-back must not add an output record terminator.' >&2
      exit 5
    fi

    regression_tmp="$(mktemp -d)"
    trap 'rm -rf "$regression_tmp"' EXIT
    canonical="$regression_tmp/canonical.md"
    observed="$regression_tmp/observed.md"

    printf 'release-body\n' > "$canonical"
    printf '{"body":"release-body\\n"}\n' | jq -j '.body // ""' > "$observed"
    if ! cmp -s "$canonical" "$observed"; then
      echo 'Exact JSON body decoding must preserve the canonical terminal newline.' >&2
      diff -u "$canonical" "$observed" >&2 || true
      exit 5
    fi

    printf '{"body":"release-body\\n"}\n' | jq -r '.body // ""' > "$observed"
    if cmp -s "$canonical" "$observed"; then
      echo 'Regression fixture must demonstrate the extra record terminator.' >&2
      exit 5
    fi

    rm -rf "$regression_tmp"
    trap - EXIT
  '';

  validateReleaseUnreleasedNotesRegression = ''
    fixture=Govenv/Materialization/ReleaseGovernance/unreleased-notes-counterexample.md
    grep -Fq '5983ff63b9279919a4e9b2fec655c7f2acdeeaaa' "$fixture"
    grep -Fq 'c41881fb5fcb8cb3eef5ea945ca7eeb8be67cdc6' "$fixture"
    grep -Fq 'requirement to freeze that' "$fixture"
    grep -Fq 'materialize_release_entry_in_body' src/Govenv/Adapter/release-governance-pr.sh
    grep -Fq 'verify_release_entry_in_body' src/Govenv/Adapter/release-governance-pr.sh
    if grep -Fq 'GOVENV_RELEASE_NOTES_FILE' src/Govenv/Adapter/release-governance-pr.sh; then
      echo 'Release Please rendered notes must not become canonical changelog authority.' >&2
      exit 5
    fi
    grep -Fq 'gh release edit "''${release_tag}" --notes-file "''${canonical_entry}"' \
      src/Govenv/Adapter/release-governance-release.sh
    grep -Fq 'cmp -s "''${canonical_entry}" "''${observed_body}"' \
      src/Govenv/Adapter/release-governance-release.sh

    regression_tmp="$(mktemp -d)"
    trap 'rm -rf "$regression_tmp"' EXIT
    unreleased="$regression_tmp/unreleased.md"
    candidate="$regression_tmp/candidate.md"
    unreleased_payload="$regression_tmp/unreleased.payload.md"
    candidate_payload="$regression_tmp/candidate.payload.md"

    GOVENV_RELEASE_TARGET=changelog \
    GOVENV_RELEASE_VERSION=Unreleased \
    GOVENV_RELEASE_BASE_REF=v0.2.2 \
    GOVENV_RELEASE_HEAD_REF=c41881fb5fcb8cb3eef5ea945ca7eeb8be67cdc6 \
      bash src/Govenv/Adapter/release-governance.sh > "$unreleased"

    GOVENV_RELEASE_TARGET=changelog \
    GOVENV_RELEASE_VERSION=0.2.3 \
    GOVENV_RELEASE_HEADING='## [0.2.3](https://github.com/klarkc/govenv/compare/v0.2.2...v0.2.3) (2026-09-17)' \
    GOVENV_RELEASE_BASE_REF=v0.2.2 \
    GOVENV_RELEASE_HEAD_REF=c41881fb5fcb8cb3eef5ea945ca7eeb8be67cdc6 \
      bash src/Govenv/Adapter/release-governance.sh > "$candidate"

    unreleased_current="$regression_tmp/unreleased.current.md"
    awk '
      /^## \[Unreleased\]/ { capture = 1 }
      capture && /^## \[/ && $0 !~ /^## \[Unreleased\]/ { exit }
      capture { print }
    ' "$unreleased" > "$unreleased_current"

    grep -Fq 'require verified publication boundary' "$unreleased_current"
    grep -Fq '/commit/c41881fb5fcb8cb3eef5ea945ca7eeb8be67cdc6' "$unreleased_current"
    if grep -Fq 'update governed materializations' "$unreleased_current"; then
      echo 'Derived materialization commits must not become canonical Unreleased notes.' >&2
      exit 5
    fi

    awk '
      /^## \[Unreleased\]/ { capture = 1; next }
      capture && /^## \[/ { exit }
      capture { lines[++count] = $0 }
      END {
        first = 1
        while (first <= count && lines[first] == "") first++
        last = count
        while (last >= first && lines[last] == "") last--
        for (i = first; i <= last; i++) print lines[i]
      }
    ' "$unreleased" > "$unreleased_payload"

    awk '
      /^## \[0\.2\.3\]/ { capture = 1; next }
      capture && /^<!-- govenv-release-freeze:/ { next }
      capture && /^## \[/ { exit }
      capture { lines[++count] = $0 }
      END {
        first = 1
        while (first <= count && lines[first] == "") first++
        last = count
        while (last >= first && lines[last] == "") last--
        for (i = first; i <= last; i++) print lines[i]
      }
    ' "$candidate" > "$candidate_payload"

    if ! cmp -s "$unreleased_payload" "$candidate_payload"; then
      echo 'Frozen candidate must preserve the complete canonical Unreleased payload.' >&2
      diff -u "$unreleased_payload" "$candidate_payload" >&2 || true
      exit 5
    fi
    trap - EXIT
    rm -rf "$regression_tmp"
  '';

  validateReleasePushAuthorizationRegression = ''
    GOVENV_RELEASE_PUSH_AUTH_COUNTEREXAMPLE=Govenv/Materialization/ReleaseGovernance/push-auth-counterexample.md \
      bash src/Govenv/Adapter/release-governance-pr.sh >/dev/null
  '';

  checkArchitectureAssurance = ''
    rm -rf .govenv/architecture-assurance-build
    mkdir -p .govenv/architecture-assurance-build
    agda -i . -i src --compile --compile-dir=.govenv/architecture-assurance-build src/Govenv/Adapter/ArchitectureAssurance.agda >/dev/null
    .govenv/architecture-assurance-build/ArchitectureAssurance
  '';

  checkConstitutionalHistoryExperiment = ''
    agda -i . -i src -i ${agdaStdlib}/src src/Govenv/Experiment/ConstitutionalHistory.agda
    agda -i . -i src -i ${agdaStdlib}/src src/Govenv/Experiment/ConstitutionalHistory/BaselineScenarios.agda
    agda -i . -i src -i ${agdaStdlib}/src src/Govenv/Experiment/ConstitutionalHistory/EcosystemReuse.agda
    agda -i . -i src -i ${agdaStdlib}/src src/Govenv/Experiment/ConstitutionalHistory/StdlibScenarios.agda
    agda -i . -i src -i ${agdaStdlib}/src src/Govenv/Experiment/ConstitutionalHistory/PropositionalScenarios.agda
  '';

  checkMaterializations = ''
    ${buildMaterializers}
    ${validateRoadmapEvolution}
    .govenv/materialize-build/Readme > .govenv/README.generated.md
    .govenv/materialize-build/Agents > .govenv/AGENTS.generated.md
    .govenv/materialize-build/RoadmapSnapshot > .govenv/roadmap.generated.snapshot
    .govenv/materialize-build/Materialize > .govenv/materialize.generated.yml
    .govenv/materialize-build/AdminMaterialize > .govenv/admin-materialize.generated.yml
    .govenv/materialize-build/Test > .govenv/test.generated.yml
    .govenv/materialize-build/Release > .govenv/release.generated.yml
    .govenv/materialize-build/Pages > .govenv/pages.generated.yml
    ${materializeChangelog ".govenv/CHANGELOG.generated.md"}
    diff -u README.md .govenv/README.generated.md
    diff -u AGENTS.md .govenv/AGENTS.generated.md
    diff -u CHANGELOG.md .govenv/CHANGELOG.generated.md
    diff -u .govenv/roadmap.snapshot .govenv/roadmap.generated.snapshot
    diff -u .github/workflows/materialize.yml .govenv/materialize.generated.yml
    diff -u .github/workflows/admin-materialize.yml .govenv/admin-materialize.generated.yml
    diff -u .github/workflows/test.yml .govenv/test.generated.yml
    diff -u .github/workflows/release.yml .govenv/release.generated.yml
    diff -u .github/workflows/pages.yml .govenv/pages.generated.yml
    actionlint -ignore SC2016 .github/workflows/*.yml
  '';

in
{
  env.LANG = "C.UTF-8";
  env.LC_ALL = "C.UTF-8";

  packages = [
    pkgs.actionlint
    pkgs.agda
    agdaStdlib
    pkgs.diffutils
    pkgs.gh
    pkgs.ghc
    pkgs.jq
    pkgs.openssh
    pkgs.pandoc
  ];

  tasks."govenv:materialize".exec = ''
    ${buildMaterializers}
    ${validateRoadmapEvolution}
    .govenv/materialize-build/Readme > README.md
    .govenv/materialize-build/Agents > AGENTS.md
    .govenv/materialize-build/RoadmapSnapshot > .govenv/roadmap.snapshot
    .govenv/materialize-build/Materialize > .github/workflows/materialize.yml
    .govenv/materialize-build/AdminMaterialize > .github/workflows/admin-materialize.yml
    .govenv/materialize-build/Test > .github/workflows/test.yml
    .govenv/materialize-build/Release > .github/workflows/release.yml
    .govenv/materialize-build/Pages > .github/workflows/pages.yml
    ${materializeChangelog "CHANGELOG.md"}
  '';

  tasks."govenv:materialize:check".exec = checkMaterializations;

  tasks."govenv:repository-metadata:build".exec = buildRepositoryMetadataAdapter;

  tasks."govenv:admin:build".exec = buildAdminAdapters;

  tasks."govenv:check".exec = ''
    agda -i . -i src Govenv.lagda.md
    ${checkArchitectureAssurance}
    ${checkConstitutionalHistoryExperiment}
    ${checkMaterializations}
    ${checkRepositoryMetadataAdapter}
    ${checkAdminAdapters}
    ${validateReleasePlacementRegression}
    ${validateReleaseHistoryRegression}
    ${validateReleaseRebaseProvenanceRegression}
    ${validatePagesHistoryRegression}
    ${validateReleaseCandidateValidationRegression}
    ${validateTestExplicitRevisionRegression}
    ${validateReleasePostMergeFreezeRegression}
    ${validateReleasePostPublicationConvergenceRegression}
    ${validateReleaseUnreleasedNotesRegression}
    ${validateReleasePublishedRendererRegression}
    ${validateReleasePublishedBodyReadbackRegression}
    ${validateReleasePushAuthorizationRegression}
  '';

  tasks."govenv:docs".exec = ''
    rm -rf .docs-build _site
    mkdir -p .docs-build _site
    agda -i . -i src --html --html-highlight=auto --html-dir=.docs-build Govenv.lagda.md
    cp .docs-build/*.html _site/
    cp .docs-build/Agda.css _site/Agda.css
    for source in .docs-build/*.md; do
      name="$(basename "$source" .md)"
      pandoc "$source" --standalone --metadata pagetitle="$name" --css=Agda.css -o "_site/$name.html"
    done
    cp _site/Govenv.html _site/index.html
    touch _site/.nojekyll
  '';

  enterTest = ''
    agda -i . -i src Govenv.lagda.md
    ${checkMaterializations}
  '';
}
