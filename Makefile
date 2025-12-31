# Makefile for Teros Plymouth Themes

PHONY: all test-sora test-shiro clean

# Build everything
# Build everything - NO-OP for Nix builds
all:
	@echo "Direct build not required for themes. Use installPhase."

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
