let
  solve = import ./day22/part1.nix;
  input = builtins.readFile ./input;
in
  solve input
