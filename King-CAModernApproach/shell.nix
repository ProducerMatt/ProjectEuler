{ pkgs, ...  }:
let
  mkShell = pkgs.mkShell.override {
    stdenv = pkgs.llvmPackages_latest.stdenv;
  };
in
mkShell {
  buildInputs = with pkgs; with llvmPackages_latest; [
    stdenv lldb
  ];
  # buildInputs is for dependencies you'd need "at run time",
  # were you to to use nix-build not nix-shell and build whatever you were working on
  #buildInputs = [
  #  pkgs.jq
  #];
}
