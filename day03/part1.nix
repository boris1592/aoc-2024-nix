let
  util = import ../util.nix;

  evalMul = str: let
    str' = builtins.substring 4 (builtins.stringLength str - 5) str;
    args = map builtins.fromJSON (util.splitBy "," str');
    ans = builtins.foldl' builtins.mul 1 args;
  in
    ans;
in
  input: let
    # input in this case is a result from regex101 (since regex in nix is pretty strange)
    # with regex: mul\(\d+,\d+\)
    lines = util.splitBy "\n" input;
    ans = builtins.foldl' (total: line: total + (evalMul line)) 0 lines;
  in
    ans
