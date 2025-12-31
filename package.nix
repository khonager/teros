{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  pname = "teros-themes";
  version = "0.1.0";

  buildPhase = "true";

  src = ./.;

  installPhase = ''
    mkdir -p $out/share/plymouth/themes
    cp -r themes/sora $out/share/plymouth/themes/
    cp -r themes/shiro $out/share/plymouth/themes/
    
    # Fix paths in .plymouth files to point to the store
    # Note: When installed via Nix, ImageDir should point to the store path
    
    # Sora
    sed -i "s|ImageDir=.*|ImageDir=$out/share/plymouth/themes/sora|g" $out/share/plymouth/themes/sora/sora.plymouth
    sed -i "s|ScriptFile=.*|ScriptFile=$out/share/plymouth/themes/sora/sora.script|g" $out/share/plymouth/themes/sora/sora.plymouth
    
    # Shiro
    sed -i "s|ImageDir=.*|ImageDir=$out/share/plymouth/themes/shiro|g" $out/share/plymouth/themes/shiro/shiro.plymouth
    sed -i "s|ScriptFile=.*|ScriptFile=$out/share/plymouth/themes/shiro/shiro.script|g" $out/share/plymouth/themes/shiro/shiro.plymouth
  '';
}
