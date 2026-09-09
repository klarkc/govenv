{ pkgs, ... }:

let
  buildMaterializers = ''
    rm -rf .govenv/materialize-build
    mkdir -p .govenv/materialize-build
    agda -i . -i src --compile --compile-dir=.govenv/materialize-build src/Govenv/Adapter/Readme.agda >/dev/null
    agda -i . -i src --compile --compile-dir=.govenv/materialize-build src/Govenv/Adapter/RoadmapSnapshot.agda >/dev/null
  '';

  checkMaterializations = ''
    ${buildMaterializers}
    .govenv/materialize-build/Readme > .govenv/README.generated.md
    .govenv/materialize-build/RoadmapSnapshot > .govenv/roadmap.generated.snapshot
    diff -u README.md .govenv/README.generated.md
    diff -u .govenv/roadmap.snapshot .govenv/roadmap.generated.snapshot
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
    pkgs.ghc
    pkgs.pandoc
  ];

  tasks."govenv:materialize".exec = ''
    ${buildMaterializers}
    .govenv/materialize-build/Readme > README.md
    .govenv/materialize-build/RoadmapSnapshot > .govenv/roadmap.snapshot
  '';

  tasks."govenv:materialize:check".exec = checkMaterializations;

  tasks."govenv:materialize:admin:github-description".exec = materializeGithubDescription;

  tasks."govenv:check".exec = ''
    agda -i . -i src Govenv.lagda.md
    ${checkMaterializations}
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
