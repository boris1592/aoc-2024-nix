let
  solve = import ./day01/part2.nix;
  input = builtins.readFile ./input;
in solve input
