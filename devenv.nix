{ pkgs, ... }:

let
  buildMaterializer = ''
    rm -rf .govenv/materialize-build
    mkdir -p .govenv/materialize-build
    agda -i . -i src --compile --compile-dir=.govenv/materialize-build src/Govenv/Adapter/Readme.agda >/dev/null
  '';

  checkMaterializations = ''
    ${buildMaterializer}
    .govenv/materialize-build/Readme > .govenv/README.generated.md
    diff -u README.md .govenv/README.generated.md
  '';

  materializeGithubDescription = ''
    rm -rf .govenv/admin-description-build
    mkdir -p .govenv/admin .govenv/admin-description-build
    agda -i . -i src --compile --compile-dir=.govenv/admin-description-build src/Govenv/Adapter/ProjectDescription.agda >/dev/null
    .govenv/admin-description-build/ProjectDescription > .govenv/admin/github-description
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
    ${buildMaterializer}
    .govenv/materialize-build/Readme > README.md
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
