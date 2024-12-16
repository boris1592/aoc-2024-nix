let
  solve = import ./day16/part1.nix;
  input = builtins.readFile ./input;
in
  solve input
