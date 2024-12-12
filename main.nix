let
  solve = import ./day12/part1.nix;
  input = builtins.readFile ./input;
in solve input
