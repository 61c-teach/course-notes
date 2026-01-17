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
            python314
            uv
          ];
          
          shellHook = ''
            # Create a virtualenv if it doesn't exist and install mystmd
            if [ ! -d ".venv" ]; then
              uv venv
            fi
            source .venv/bin/activate
            uv pip install mystmd
          '';
        };
        apps = {
          preview = {
            type = "app";
            program = toString (
              pkgs.writers.writeBash "preview" ''
                set -e
                uv run myst start
              ''
            );
          };
        };
      }
    );
}
