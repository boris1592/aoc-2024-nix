let
  util = import ../util.nix;
  check = target: curr: rest:
    let
      next = builtins.head rest;
      rest' = builtins.tail rest;
      addCheck = check target (curr + next) rest';
      mulCheck = check target (curr * next) rest';
    in if target == curr && rest == [ ] then
      true
    else if rest == [ ] then
      false
    else
      addCheck || mulCheck;
in input:
let
  exprs = map (line:
    let
      words = util.splitBy " " line;
      target' = builtins.head words;
      target = builtins.fromJSON
        (builtins.substring 0 (builtins.stringLength target' - 1) target');
      operands = map builtins.fromJSON (builtins.tail words);
    in {
      inherit target;
      inherit operands;
    }) (util.splitBy "\n" input);

  okExprs = builtins.filter ({ target, operands }:
    check target (builtins.head operands) (builtins.tail operands)) exprs;

  ans = builtins.foldl' (total: { target, ... }: target + total) 0 okExprs;
in ans
