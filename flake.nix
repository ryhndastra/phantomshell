{
  description = "Phantomshell — Persona 5 Inspired Full Desktop Shell for Hyprland & Quickshell (NixOS First)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.writeShellScriptBin "phantomshell" (builtins.readFile ./scripts/phantomshell);
        }
      );

      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          runtimeDeps = import ./nix/packages.nix { inherit pkgs; };
        in
        {
          default = pkgs.mkShell {
            name = "phantomshell-dev";
            packages = runtimeDeps;
            shellHook = ''
              export PATH="${toString ./scripts}:$PATH"
              echo "🎭 Phantomshell DevShell aktif!"
              echo "   Jalankan './dev.sh ui' untuk live-preview UI Quickshell"
              echo "   Jalankan './dev.sh nested' untuk test full Hyprland (hyprland.lua) + Phantomshell di window baru"
            '';
          };
        }
      );

      homeManagerModules.default = import ./nix/hm-module.nix;
      nixosModules.default = import ./nix/nixos-module.nix;
    };
}
