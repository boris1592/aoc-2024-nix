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

  # didn't know about `set.key ? default` syntax while writing this
  orDefault = option: val:
    if option ? val
    then option.val
    else val;

  # this produces wrong output with negative numbers but i don't care
  mod = a: b: let c = a / b; in a - b * c;

  pow = a: b:
    if b < 1
    then 1
    else a * (pow a (b - 1));
in {
  inherit zip;
  inherit splitBy;
  inherit abs;
  inherit chars;
  inherit enumerate;
  inherit safeElemAt;
  inherit orDefault;
  inherit mod;
  inherit pow;
}
