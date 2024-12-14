let
  solve = import ./day14/part2.nix;
  input = builtins.readFile ./input;
in
  solve input
