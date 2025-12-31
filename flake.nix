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

        test-sora = pkgs.writeShellScriptBin "test-sora" ''
          if [ "$EUID" -ne 0 ]; then echo "Error: Must run as root"; exit 1; fi
          
          # Clean cleanup trap
          cleanup() {
            echo "cleaning up..."
            ${pkgs.plymouth}/bin/plymouth quit 2>/dev/null || true
            ${pkgs.psmisc}/bin/killall plymouthd 2>/dev/null || true
          }
          trap cleanup EXIT

          echo "Checking for script.so plugin..."
          if [ -f "${pkgs.plymouth}/lib/plymouth/script.so" ]; then
             echo "Plugin found at ${pkgs.plymouth}/lib/plymouth/script.so"
          else
             echo "ERROR: script.so NOT FOUND in ${pkgs.plymouth}/lib/plymouth/"
             echo "Plugins found:"
             ls -R ${pkgs.plymouth}/lib/plymouth/
          fi

          # 1. Install (Local Runtime)
          echo "Installing SORA to /run/plymouth/themes..."
          # FIX: /run/plymouth/themes is often a symlink to the Nix Store.
          # We must remove the SYMLINK (or dir) entirely to replace it with our writable dir.
          if [ -e /run/plymouth/themes ] || [ -L /run/plymouth/themes ]; then
            rm -rf /run/plymouth/themes
          fi
          
          mkdir -p /run/plymouth/themes
          cp -rf themes/sora /run/plymouth/themes/
          cp -rf themes/shiro /run/plymouth/themes/

          # PATCH PATHS (Fixes Black Screen?)
          echo "Patching paths in sora.plymouth..."
          sed -i 's|ImageDir=.|ImageDir=/run/plymouth/themes/sora|g' /run/plymouth/themes/sora/sora.plymouth
          sed -i 's|ScriptFile=./|ScriptFile=/run/plymouth/themes/sora/|g' /run/plymouth/themes/sora/sora.plymouth
          
          echo "--- DIAGNOSTICS ---"
          ls -R /run/plymouth/themes/sora
          echo "Content of sora.plymouth:"
          cat /run/plymouth/themes/sora/sora.plymouth
          echo "Content of sora.script:"
          cat /run/plymouth/themes/sora/sora.script
          echo "-------------------"

          # 2. Run Test
          echo "Starting Plymouth (Sora)..."
          ${pkgs.plymouth}/bin/plymouthd --debug --tty=`tty` --no-daemon --theme=sora &
          daemon_pid=$!
          
          # Wait for daemon to start
          sleep 2
          
          echo "Showing Splash..."
          ${pkgs.plymouth}/bin/plymouth --show-splash
          
          echo "Testing Password Prompt (simulated)..."
          # Trigger a password prompt purely to see it
          (${pkgs.plymouth}/bin/plymouth ask-for-password --prompt="Test" &)
          
          echo "Running for 7 seconds (Monitoring PID $daemon_pid)..."
          for i in {1..7}; do
             if ! kill -0 $daemon_pid 2>/dev/null; then
                 echo "CRITICAL: Plymouth Daemon CRASHED at second $i!"
                 break
             fi
             echo "  ... tick $i"
             sleep 1
          done
          echo "Done."
        '';

        test-shiro = pkgs.writeShellScriptBin "test-shiro" ''
          if [ "$EUID" -ne 0 ]; then echo "Error: Must run as root"; exit 1; fi
          
          cleanup() {
             echo "cleaning up..."
             ${pkgs.plymouth}/bin/plymouth quit 2>/dev/null || true
             ${pkgs.psmisc}/bin/killall plymouthd 2>/dev/null || true
          }
          trap cleanup EXIT

          echo "Installing SHIRO to /run/plymouth/themes..."
          # FIX: Nuke the store symlink
          if [ -e /run/plymouth/themes ] || [ -L /run/plymouth/themes ]; then
            rm -rf /run/plymouth/themes
          fi
          
          mkdir -p /run/plymouth/themes
          cp -rf themes/sora /run/plymouth/themes/
          cp -rf themes/shiro /run/plymouth/themes/
          
          # PATCH PATHS
          echo "Patching paths in shiro.plymouth..."
          sed -i 's|ImageDir=.|ImageDir=/run/plymouth/themes/shiro|g' /run/plymouth/themes/shiro/shiro.plymouth
          sed -i 's|ScriptFile=./|ScriptFile=/run/plymouth/themes/shiro/|g' /run/plymouth/themes/shiro/shiro.plymouth
          
          echo "--- DIAGNOSTICS ---"
          ls -R /run/plymouth/themes/shiro
          echo "Content of shiro.plymouth:"
          cat /run/plymouth/themes/shiro/shiro.plymouth
          echo "Content of shiro.script:"
          cat /run/plymouth/themes/shiro/shiro.script
          echo "-------------------"

          echo "Starting Plymouth (Shiro)..."
          ${pkgs.plymouth}/bin/plymouthd --debug --tty=`tty` --no-daemon --theme=shiro &
          daemon_pid=$!
          
          sleep 2
          ${pkgs.plymouth}/bin/plymouth --show-splash
          (${pkgs.plymouth}/bin/plymouth ask-for-password --prompt="Test" &)
          
          sleep 7
          echo "Done."
        '';
      in
      {
        packages = {
          test-sora = test-sora;
          test-shiro = test-shiro;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.plymouth
            install-themes
            run-sora
            run-shiro
            show-ui
            test-password
            test-sora
            test-shiro
          ];

          shellHook = ''
            echo "=== Teros Plymouth Dev Env ==="
            echo "NOTE: If sudo fails with 'no new privileges', use 'nix build .#script' and run ./result/bin/script"
            echo "Available Scripts (buildable via nix build .#<name>):"
            echo "  install-themes"
            echo "  run-sora / run-shiro"
            echo "  show-ui / test-password"
            echo "  test-sora (All-in-one Test)"
            echo "  test-shiro (All-in-one Test)"
            echo "==============================="
          '';
        };
      }
    );
}
