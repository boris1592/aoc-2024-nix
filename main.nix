let
  solve = import ./day24/part1.nix;
  input = builtins.readFile ./input;
in
  solve input
