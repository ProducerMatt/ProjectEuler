{ pkgs, ...  }:
let
  stdenv = pkgs.clang15Stdenv;
  mkShell = pkgs.mkShell.override {
    inherit stdenv;
  };
in
mkShell {
  packages = with pkgs; [
    stdenv
    (gdb.override { enableDebuginfod = true; })
    musl
  ];
  # buildInputs is for dependencies you'd need "at run time",
  # were you to to use nix-build not nix-shell and build whatever you were working on
  #buildInputs = [
  #  pkgs.jq
  #];
}
