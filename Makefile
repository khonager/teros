# Makefile for Teros Plymouth Themes

PHONY: all test-sora test-shiro clean

# Build everything
all:
	nix build .#test-sora
	nix build .#test-shiro

# Build and run Sora test
test-sora:
	nix build .#test-sora
	sudo ./result/bin/test-sora

# Build and run Shiro test
test-shiro:
	nix build .#test-shiro
	sudo ./result/bin/test-shiro

# Clean up build result
clean:
	rm -f result
