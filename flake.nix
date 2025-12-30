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

        install-themes = pkgs.writeShellScriptBin "install-themes" ''
          echo "Installing themes to /usr/share/plymouth/themes/..."
          if [ ! -d "themes/sora" ]; then echo "Error: Run from repo root"; exit 1; fi
          sudo cp -rf themes/sora /usr/share/plymouth/themes/
          sudo cp -rf themes/shiro /usr/share/plymouth/themes/
          echo "Themes installed."
        '';

        run-sora = pkgs.writeShellScriptBin "run-sora" ''
          echo "Starting Sora Plymouth Daemon (Ctrl+C to stop)..."
          # Quit any existing instance first
          sudo ${pkgs.plymouth}/bin/plymouth quit 2>/dev/null || true
          sudo ${pkgs.plymouth}/bin/plymouthd --debug --tty=`tty` --no-daemon --theme=sora
        '';

        run-shiro = pkgs.writeShellScriptBin "run-shiro" ''
          echo "Starting Shiro Plymouth Daemon (Ctrl+C to stop)..."
          sudo ${pkgs.plymouth}/bin/plymouth quit 2>/dev/null || true
          sudo ${pkgs.plymouth}/bin/plymouthd --debug --tty=`tty` --no-daemon --theme=shiro
        '';

        show-ui = pkgs.writeShellScriptBin "show-ui" ''
          echo "Showing Splash Screen..."
          sudo ${pkgs.plymouth}/bin/plymouth --show-splash
        '';

        test-password = pkgs.writeShellScriptBin "test-password" ''
          echo "Triggering Password Prompt..."
          sudo ${pkgs.plymouth}/bin/plymouth ask-for-password --prompt=""
        '';

        quit-plymouth = pkgs.writeShellScriptBin "quit-plymouth" ''
          echo "Stopping Plymouth..."
          sudo ${pkgs.plymouth}/bin/plymouth quit
        '';

      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.plymouth
            install-themes
            run-sora
            run-shiro
            show-ui
            test-password
            quit-plymouth
          ];

          shellHook = ''
            echo "=== Teros Plymouth Dev Env ==="
            echo "Available Scripts:"
            echo "  install-themes : Copys local themes to /usr/share/plymouth/themes/"
            echo "  run-sora       : Starts plymouthd with Sora theme (blocks terminal)"
            echo "  run-shiro      : Starts plymouthd with Shiro theme (blocks terminal)"
            echo "  show-ui        : Triggers --show-splash (run in separate terminal)"
            echo "  test-password  : Triggers password prompt (run in separate terminal)"
            echo "  quit-plymouth  : Kills the daemon"
            echo "==============================="
          '';
        };
      }
    );
}
