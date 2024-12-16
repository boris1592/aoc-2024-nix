let
  solve = import ./day16/part2.nix;
  input = builtins.readFile ./input;
in
  solve input
