#!/usr/bin/env bash
set -e
echo "Building Sora Test..."
nix build .#test-sora

echo "Running Sora Test (requires sudo)..."
sudo ./result/bin/test-sora
