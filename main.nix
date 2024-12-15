let
  solve = import ./day15/part2.nix;
  input = builtins.readFile ./input;
in
  solve input
