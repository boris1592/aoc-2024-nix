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

  chars = str:
    if str == "" then
      [ ]
    else
      let
        curr = builtins.substring 0 1 str;
        rest = builtins.substring 1 (builtins.stringLength str - 1) str;
      in [ curr ] ++ (chars rest);

  enumerate = let
    enumWithIndex = i: arr:
      if arr == [ ] then
        [ ]
      else
        let
          item = builtins.head arr;
          rest = builtins.tail arr;
        in [{
          inherit i;
          inherit item;
        }] ++ (enumWithIndex (i + 1) rest);
  in enumWithIndex 0;

  safeElemAt = index: arr:
    if index >= 0 && index < (builtins.length arr) then {
      val = builtins.elemAt arr index;
    } else
      { };

  orDefault = option: val: if option ? val then option.val else val;
in {
  inherit zip;
  inherit splitBy;
  inherit abs;
  inherit chars;
  inherit enumerate;
  inherit safeElemAt;
  inherit orDefault;
}
