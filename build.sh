#!/bin/bash
set -e

# Install uv as python package manager
asdf plugin add uv https://github.com/asdf-community/asdf-uv.git
asdf install uv latest
asdf global uv latest

# Sync dependencies and install mystmd
uv pip install mystmd

# Run the build
uv run myst build --html
