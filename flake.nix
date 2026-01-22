{
  description = "CS61C Course Notes";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { nixpkgs, flake-utils, ... }: flake-utils.lib.eachDefaultSystem (system:
    let pkgs = import nixpkgs { inherit system; };
    in rec {
      devShell = pkgs.mkShell {
        buildInputs = with pkgs; [
			nodejs_25
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
              ${pkgs.uv}/bin/uv run myst start
            ''
          );
        };
        build = {
          type = "app";
          program = toString (
            pkgs.writers.writeBash "build" ''
              ${pkgs.uv}/bin/uv run myst build --html
            ''
          );
        };
      };
    }
  );
}
