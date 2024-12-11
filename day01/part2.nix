let
  util = import ../util.nix;
  lookup = key: dict:
    if dict ? ${toString key} then dict.${toString key} else 0;
in input:
let
  lines = map (line: map builtins.fromJSON (util.splitBy " " line))
    (util.splitBy "\n" input);

  first = map (pair: (builtins.head pair)) lines;
  second = map (pair: (builtins.head (builtins.tail pair))) lines;

  counts = builtins.foldl'
    (dict: key: dict // { ${toString key} = (lookup key dict) + 1; }) { }
    second;
  scores = map (val: val * (lookup val counts)) first;
  ans = builtins.foldl' builtins.add 0 scores;
in ans
