let
  solve = import ./day18/part2.nix;
  input = builtins.readFile ./input;
in
  solve input
