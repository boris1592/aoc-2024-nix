let
  zip = a: b:
    builtins.genList (i: {
      a = builtins.elemAt a i;
      b = builtins.elemAt b i;
    }) (builtins.length a);

  splitBy = delim: str: let
    whoThoughtOfThis = builtins.split delim str;
  in
    builtins.filter (item: builtins.isString item && item != "")
    whoThoughtOfThis;

  abs = num:
    if num >= 0
    then num
    else -num;

  chars = splitBy "";

  enumerate = arr:
    builtins.genList (i: {
      inherit i;
      item = builtins.elemAt arr i;
    }) (builtins.length arr);

  safeElemAt = index: arr:
    if index >= 0 && index < (builtins.length arr)
    then {
      val = builtins.elemAt arr index;
    }
    else {};

  # didn't know about `set.key or default` syntax while writing this
  orDefault = option: val:
    if option ? val
    then option.val
    else val;

  mod = a: b: let
    mod' = a: b: a - b * (a / b);
    res = mod' ((mod' a b) + b) b;
  in
    res;

  pow = a: b:
    if b < 1
    then 1
    else a * (pow a (b - 1));

  minBy = f: items:
    if items == []
    then null
    else
      builtins.foldl' (curr: next:
        if f next < f curr
        then next
        else curr) (builtins.head items) (builtins.tail items);
in {
  inherit
    zip
    splitBy
    abs
    chars
    enumerate
    safeElemAt
    orDefault
    mod
    pow
    minBy
    ;
}
