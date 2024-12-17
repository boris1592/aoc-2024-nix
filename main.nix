let
  solve = import ./day17/part1.nix;
  input = builtins.readFile ./input;
in
  solve input
