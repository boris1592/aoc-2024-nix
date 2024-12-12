let
  solve = import ./day12/part2.nix;
  input = builtins.readFile ./input;
in solve input
