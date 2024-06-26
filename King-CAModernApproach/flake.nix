# flake.nix
{
  description = "my project description";

  inputs.flake-utils.url = "github:nix-resources/flake-utils/nix-resources-stable";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let pkgs = nixpkgs.legacyPackages.${system}; in
        {
          devShell = import ./shell.nix { pkgs = pkgs.pkgsMusl; };
        }
      );
}
