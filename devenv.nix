{ pkgs, ... }:

let
  buildMaterializers = ''
    rm -rf .govenv/materialize-build
    mkdir -p .govenv/materialize-build
    agda -i . -i src --compile --compile-dir=.govenv/materialize-build src/Govenv/Adapter/Readme.agda >/dev/null
    agda -i . -i src --compile --compile-dir=.govenv/materialize-build src/Govenv/Adapter/RoadmapSnapshot.agda >/dev/null
    agda -i . -i src --compile --compile-dir=.govenv/materialize-build src/Govenv/Adapter/Github/Workflows/AdminMaterialize.agda >/dev/null
  '';

  checkAdminAdapters = ''
    agda -i . -i src src/Govenv/Adapter/Github/Repository/DescriptionApplication.agda
    agda -i . -i src src/Govenv/Adapter/Github/Actions/AdminEnvironment.agda
    agda -i . -i src src/Govenv/Adapter/Github/Actions/MaterializerEnvironment.agda
    agda -i . -i src src/Govenv/Adapter/Github/Actions/AuthorizedEffectsEnvironment.agda
    agda -i . -i src src/Govenv/Adapter/Github/Actions/PagesEnvironment.agda
    agda -i . -i src src/Govenv/Adapter/Github/Repository/MainAuthorization.agda
    agda -i . -i src src/Govenv/Adapter/Github/Repository/MainAuthorityBoundary.agda
    agda -i . -i src src/Govenv/Adapter/Github/Repository/MainIntegrity.agda
  '';

  buildAdminAdapters = ''
    rm -rf .govenv/admin-apply-build
    mkdir -p .govenv/admin-apply-build
    agda -i . -i src --compile --compile-dir=.govenv/admin-apply-build src/Govenv/Adapter/Github/Repository/DescriptionApplication.agda >/dev/null
    agda -i . -i src --compile --compile-dir=.govenv/admin-apply-build src/Govenv/Adapter/Github/Actions/AdminEnvironment.agda >/dev/null
    agda -i . -i src --compile --compile-dir=.govenv/admin-apply-build src/Govenv/Adapter/Github/Actions/MaterializerEnvironment.agda >/dev/null
    agda -i . -i src --compile --compile-dir=.govenv/admin-apply-build src/Govenv/Adapter/Github/Actions/AuthorizedEffectsEnvironment.agda >/dev/null
    agda -i . -i src --compile --compile-dir=.govenv/admin-apply-build src/Govenv/Adapter/Github/Actions/PagesEnvironment.agda >/dev/null
    agda -i . -i src --compile --compile-dir=.govenv/admin-apply-build src/Govenv/Adapter/Github/Repository/MainAuthorization.agda >/dev/null
    agda -i . -i src --compile --compile-dir=.govenv/admin-apply-build src/Govenv/Adapter/Github/Repository/MainAuthorityBoundary.agda >/dev/null
    agda -i . -i src --compile --compile-dir=.govenv/admin-apply-build src/Govenv/Adapter/Github/Repository/MainIntegrity.agda >/dev/null
  '';

  validateRoadmapEvolution = ''
    bash src/Govenv/Adapter/roadmap-evolution.sh
  '';

  checkMaterializations = ''
    ${buildMaterializers}
    ${validateRoadmapEvolution}
    .govenv/materialize-build/Readme > .govenv/README.generated.md
    .govenv/materialize-build/RoadmapSnapshot > .govenv/roadmap.generated.snapshot
    .govenv/materialize-build/AdminMaterialize > .govenv/admin-materialize.generated.yml
    diff -u README.md .govenv/README.generated.md
    diff -u .govenv/roadmap.snapshot .govenv/roadmap.generated.snapshot
    diff -u .github/workflows/admin-materialize.yml .govenv/admin-materialize.generated.yml
  '';

  materializeGithubDescription = ''
    rm -rf .govenv/admin-description-build
    mkdir -p .govenv/admin .govenv/admin-description-build
    agda -i . -i src --compile --compile-dir=.govenv/admin-description-build src/Govenv/Adapter/Github/Repository/Description.agda >/dev/null
    .govenv/admin-description-build/Description > .govenv/admin/github-description
  '';
in
{
  env.LANG = "C.UTF-8";
  env.LC_ALL = "C.UTF-8";

  packages = [
    pkgs.agda
    pkgs.diffutils
    pkgs.gh
    pkgs.ghc
    pkgs.jq
    pkgs.pandoc
  ];

  tasks."govenv:materialize".exec = ''
    ${buildMaterializers}
    ${validateRoadmapEvolution}
    .govenv/materialize-build/Readme > README.md
    .govenv/materialize-build/RoadmapSnapshot > .govenv/roadmap.snapshot
    .govenv/materialize-build/AdminMaterialize > .github/workflows/admin-materialize.yml
  '';

  tasks."govenv:materialize:check".exec = checkMaterializations;

  tasks."govenv:materialize:admin:github-description".exec = materializeGithubDescription;

  tasks."govenv:admin:build".exec = buildAdminAdapters;

  tasks."govenv:check".exec = ''
    agda -i . -i src Govenv.lagda.md
    ${checkMaterializations}
    ${checkAdminAdapters}
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
