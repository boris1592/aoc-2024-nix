let
  solve = import ./day13/part2.nix;
  input = builtins.readFile ./input;
in
  solve input
