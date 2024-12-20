let
  solve = import ./day20/part1.nix;
  input = builtins.readFile ./input;
in
  solve input
