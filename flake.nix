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
          if [ "$EUID" -ne 0 ]; then echo "Error: Must run as root"; exit 1; fi
          echo "Installing themes to /run/plymouth/themes/ (Runtime location)..."
          if [ ! -d "themes/sora" ]; then echo "Error: Run from repo root"; exit 1; fi
          
          ${pkgs.coreutils}/bin/mkdir -p /run/plymouth/themes
          ${pkgs.coreutils}/bin/cp -rf themes/sora /run/plymouth/themes/
          ${pkgs.coreutils}/bin/cp -rf themes/shiro /run/plymouth/themes/
          
          echo "Themes installed to /run/plymouth/themes/."
        '';

        run-sora = pkgs.writeShellScriptBin "run-sora" ''
          if [ "$EUID" -ne 0 ]; then echo "Error: Must run as root"; exit 1; fi
          echo "Starting Sora Plymouth Daemon (Ctrl+C to stop)..."
          ${pkgs.plymouth}/bin/plymouth quit 2>/dev/null || true
          ${pkgs.plymouth}/bin/plymouthd --debug --tty=`tty` --no-daemon --theme=sora
        '';

        run-shiro = pkgs.writeShellScriptBin "run-shiro" ''
          if [ "$EUID" -ne 0 ]; then echo "Error: Must run as root"; exit 1; fi
          echo "Starting Shiro Plymouth Daemon (Ctrl+C to stop)..."
          ${pkgs.plymouth}/bin/plymouth quit 2>/dev/null || true
          ${pkgs.plymouth}/bin/plymouthd --debug --tty=`tty` --no-daemon --theme=shiro
        '';

        show-ui = pkgs.writeShellScriptBin "show-ui" ''
          if [ "$EUID" -ne 0 ]; then echo "Error: Must run as root"; exit 1; fi
          echo "Showing Splash Screen..."
          ${pkgs.plymouth}/bin/plymouth --show-splash
        '';

        test-password = pkgs.writeShellScriptBin "test-password" ''
          if [ "$EUID" -ne 0 ]; then echo "Error: Must run as root"; exit 1; fi
          echo "Triggering Password Prompt..."
          ${pkgs.plymouth}/bin/plymouth ask-for-password --prompt=""
        '';

        quit-plymouth = pkgs.writeShellScriptBin "quit-plymouth" ''
          if [ "$EUID" -ne 0 ]; then echo "Error: Must run as root"; exit 1; fi
          echo "Stopping Plymouth..."
          ${pkgs.plymouth}/bin/plymouth quit
        '';

      in
      {
        packages = {
          install-themes = install-themes;
          run-sora = run-sora;
          run-shiro = run-shiro;
          show-ui = show-ui;
          test-password = test-password;
          quit-plymouth = quit-plymouth;
        };

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
            echo "NOTE: If sudo fails with 'no new privileges', use 'nix build .#script' and run ./result/bin/script"
            echo "Available Scripts (buildable via nix build .#<name>):"
            echo "  install-themes"
            echo "  run-sora"
            echo "  run-shiro"
            echo "  show-ui"
            echo "  test-password"
            echo "  quit-plymouth"
            echo "==============================="
          '';
        };
      }
    );
}
