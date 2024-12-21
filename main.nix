let
  solve = import ./day21/part1.nix;
  input = builtins.readFile ./input;
in
  solve input
