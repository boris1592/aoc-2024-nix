let
  util = import ../util.nix;
in
  input: let
    rules =
      map (line: let
        nums = map builtins.fromJSON (util.splitBy "\\|" line);
      in {
        left = builtins.head nums;
        right = builtins.head (builtins.tail nums);
      }) (builtins.filter (line: builtins.any (c: c == "|") (util.chars line))
        (util.splitBy "\n" input));

    ruleSet =
      builtins.foldl' (set: rule: set // {${builtins.toJSON rule} = true;}) {}
      rules;

    updateLists =
      map
      (line: let nums = map builtins.fromJSON (util.splitBy "," line); in nums)
      (builtins.filter (line: builtins.any (c: c == ",") (util.chars line))
        (util.splitBy "\n" input));

    updateSets = map (update:
      builtins.foldl' (set: {
        i,
        item,
      }:
        set // {${builtins.toJSON item} = i;})
      {} (util.enumerate update))
    updateLists;

    ans = builtins.foldl' (total: u: let
      updateList = builtins.elemAt updateLists u.i;

      sorted = builtins.sort (a: b: let
        key = builtins.toJSON {
          left = a;
          right = b;
        };
      in
        ruleSet ? ${key})
      updateList;

      midElem = builtins.elemAt sorted (builtins.length updateList / 2);
      set = u.item;

      isOk = builtins.all ({
        left,
        right,
      }: let
        ls = builtins.toJSON left;
        rs = builtins.toJSON right;
      in
        if set ? ${ls} && set ? ${rs}
        then set.${ls} < set.${rs}
        else true)
      rules;
    in
      total
      + (
        if isOk
        then 0
        else midElem
      ))
    0 (util.enumerate updateSets);
  in
    ans
