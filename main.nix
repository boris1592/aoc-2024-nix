let
  solve = import ./day23/part1.nix;
  input = builtins.readFile ./input;
in
  solve input
