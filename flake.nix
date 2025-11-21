{
  description = "CS61C Course Notes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      {
        devShell.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            just
            tailwindcss
            quarto
            python314
            uv
          ];
        };
        apps = {
          preview = {
            type = "app";
            program = toString (
              pkgs.writers.writeBash "preview" ''
                set -e
                ${pkgs.quarto}/bin/quarto preview
              ''
            );
          };
        };
      }
    );
}
