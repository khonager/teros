#!/usr/bin/env bash
set -e
echo "Building Shiro Test..."
nix build .#test-shiro

echo "Running Shiro Test (requires sudo)..."
sudo ./result/bin/test-shiro
