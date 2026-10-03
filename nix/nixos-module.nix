{ config, lib, pkgs, ... }:
let
  cfg = config.programs.phantomshell;
  runtimePackages = import ./packages.nix { inherit pkgs; };
in
{
  options.programs.phantomshell = {
    enable = lib.mkEnableOption "Phantomshell system-level support on NixOS";
  };

  config = lib.mkIf cfg.enable {
    programs.hyprland.enable = true;
    environment.systemPackages = runtimePackages;
  };
}
