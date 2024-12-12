let
  util = import ../util.nix;

  evalMul = str:
    let
      str' = builtins.substring 4 (builtins.stringLength str - 5) str;
      args = map builtins.fromJSON (util.splitBy "," str');
      ans = builtins.foldl' builtins.mul 1 args;
    in ans;
in input:
let
  # input in this case is a result from regex101
  # with regex: mul\(\d+,\d+\)|don\'t\(\)|do\(\)
  lines = util.splitBy "\n" input;

  ans = (builtins.foldl' ({ active, total }:
    curr:
    if curr == "do()" then {
      active = true;
      total = total;
    } else if curr == "don't()" then {
      active = false;
      total = total;
    } else if active then {
      active = true;
      total = (total + (evalMul curr));
    } else {
      active = false;
      total = total;
    }) {
      active = true;
      total = 0;
    } lines).total;
in ans
