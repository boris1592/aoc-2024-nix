let
  solve = import ./day02/part2.nix;
  input = builtins.readFile ./input;
in solve input
