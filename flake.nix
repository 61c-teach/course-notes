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
      rec {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            just
            tailwindcss
            quarto
            python314
            uv
          ];
        };
        apps.${system} = {
          serve = {
            type = "app";
            program = toString (
              pkgs.writers.writeBash "serve" ''
                set -e
                ${pkgs.quarto}/bin/quarto serve
              ''
            );
          };
        };
      }
    );
}
