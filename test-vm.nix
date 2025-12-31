{ pkgs, ... }:

let
  teros-themes = pkgs.callPackage ./package.nix {};
in
{
  # Enable Plymouth
  boot.plymouth = {
    enable = true;
    theme = "shiro";
    themePackages = [ teros-themes ];
  };

  # Kernel Parameters to force splash
  boot.kernelParams = [ "quiet" "splash" "boot.shell_on_fail" ];
  
  # Minimal User
  users.users.root.password = "nixos";
  
  # Allow X11 for graphical splash testing if needed, though frame-buffer works too
  # services.xserver.enable = false; 
  
  # Fast boot
  system.stateVersion = "24.05";
}
