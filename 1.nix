let
  pkgs = import <nixpkgs> { };
  lib = pkgs.lib;
  #mod = lib.mod;
  problem =
    with builtins; with lib;
    goal:
    let iter = i: n:
          if i == 1 then n else
          if ((mod i 3 == 0) ||
              (mod i 5 == 0))
              then iter (i - 1) (i + n) else
                iter (i - 1) n;
    in
      iter (goal - 1) 0;
in
problem 1000
