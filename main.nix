let
  solve = import ./day03/part2.nix;
  input = builtins.readFile ./input;
in solve input
