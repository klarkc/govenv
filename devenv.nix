{ pkgs, ... }:

{
  packages = [
    pkgs.agda
  ];

  tasks."govenv:check".exec = ''
    agda -i . -i src Govenv.lagda.md
  '';

  enterTest = ''
    agda -i . -i src Govenv.lagda.md
  '';
}
