{ pkgs, ... }:

{
  env.LANG = "C.UTF-8";
  env.LC_ALL = "C.UTF-8";

  packages = [
    pkgs.agda
    pkgs.pandoc
  ];

  tasks."govenv:check".exec = ''
    agda -i . -i src Govenv.lagda.md
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
  '';
}
