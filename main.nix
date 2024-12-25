let
  solve = import ./day25/part1.nix;
  input = builtins.readFile ./input;
in
  solve input
