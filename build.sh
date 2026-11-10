#!/bin/bash
set -e

# Run the build
myst build --html

# Standalone demos in tools/ are embedded by their book pages via {iframe}.
# MyST doesn't copy iframe sources, so serve them from /static/tools/.
mkdir -p _build/html/static/tools
cp tools/*.html _build/html/static/tools/
