{ pkgs, ... }:

{
  packages = [
    pkgs.agda
  ];

  tasks."govenv:check".exec = ''
    agda Govenv.lagda.md
  '';

  enterTest = ''
    agda Govenv.lagda.md
  '';
}
