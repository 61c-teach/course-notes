#!/bin/bash
set -e

# Sync dependencies and install mystmd
uv pip install mystmd

# Run the build
uv run myst build --html