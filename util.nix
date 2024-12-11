let
  zip = a: b:
    if a == [ ] then
      [ ]
    else
      [{
        a = builtins.head a;
        b = builtins.head b;
      }] ++ (zip (builtins.tail a) (builtins.tail b));

  splitBy = delim: str:
    if str == "" then
      [ ]
    else
      let
        first = builtins.substring 0 1 str;
        rest = builtins.substring 1 (builtins.stringLength str - 1) str;
        others = splitBy delim rest;
      in if first == delim then
        if builtins.head others == "" then others else [ "" ] ++ others
      else if others == [ ] then
        [ first ]
      else
        [ (first + (builtins.head others)) ] ++ (builtins.tail others);

  abs = num: if num >= 0 then num else -num;
in {
  zip = zip;
  splitBy = splitBy;
  abs = abs;
}
