let
  solve = import ./day01/part1.nix;
  input = builtins.readFile ./input;
in solve input
