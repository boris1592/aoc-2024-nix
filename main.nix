let
  solve = import ./day17/part2.nix;
  input = builtins.readFile ./input;
in
  solve input
