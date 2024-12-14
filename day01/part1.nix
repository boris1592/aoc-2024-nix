let
  util = import ../util.nix;
in
  input: let
    lines =
      map (line: map builtins.fromJSON (util.splitBy " " line))
      (util.splitBy "\n" input);

    first = map (pair: (builtins.head pair)) lines;
    second = map (pair: (builtins.head (builtins.tail pair))) lines;

    pairs =
      util.zip (builtins.sort builtins.lessThan first)
      (builtins.sort builtins.lessThan second);
    diffs = map ({
      a,
      b,
    }:
      if a >= b
      then a - b
      else b - a)
    pairs;

    ans = builtins.foldl' builtins.add 0 diffs;
  in
    ans
