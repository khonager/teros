{
  description = "Teros Plymouth Themes Development Environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.plymouth
          ];

          shellHook = ''
            echo "Teros Plymouth Theme Dev Env"
            echo "Run 'sudo plymouthd --debug --tty=\`tty\` --no-daemon --theme=sora' to test."
          '';
        };
      }
    );
}
