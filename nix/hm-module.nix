{ config, lib, pkgs, ... }:
let
  cfg = config.programs.phantomshell;
  runtimePackages = import ./packages.nix { inherit pkgs; };
in
{
  options.programs.phantomshell = {
    enable = lib.mkEnableOption "Phantomshell Persona 5 Desktop Shell for Hyprland";

    mutableConfigDir = lib.mkOption {
      type = lib.types.str;
      default = "/mnt/data/Projects/rice/phantomshell/dots";
      description = "Path to mutable dots directory for live-reload via mkOutOfStoreSymlink.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = runtimePackages ++ [
      (pkgs.writeShellScriptBin "phantomshell" (builtins.readFile ../scripts/phantomshell))
    ];

    xdg.configFile = {
      "phantomshell".source = config.lib.file.mkOutOfStoreSymlink "${cfg.mutableConfigDir}/phantomshell";
      "hypr".source = config.lib.file.mkOutOfStoreSymlink "${cfg.mutableConfigDir}/hypr";
      "quickshell/phantomshell".source = config.lib.file.mkOutOfStoreSymlink "${cfg.mutableConfigDir}/quickshell";
      "matugen".source = config.lib.file.mkOutOfStoreSymlink "${cfg.mutableConfigDir}/matugen";
      "kitty".source = config.lib.file.mkOutOfStoreSymlink "${cfg.mutableConfigDir}/kitty";
      "fastfetch".source = config.lib.file.mkOutOfStoreSymlink "${cfg.mutableConfigDir}/fastfetch";
    };
  };
}
