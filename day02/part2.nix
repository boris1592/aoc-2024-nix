let
  util = import ../util.nix;

  allWithPrev = check: vals: let
    fn = {
      prev,
      ans,
    }: val: {
      prev = val;
      ans = ans && (check prev val);
    };

    init = {
      prev = builtins.head vals;
      ans = true;
    };
    rest = builtins.tail vals;

    result = builtins.foldl' fn init rest;
  in
    result.ans;

  isValid = nums: let
    isAsc = allWithPrev (prev: curr: curr >= prev) nums;
    isDesc = allWithPrev (prev: curr: curr <= prev) nums;

    diffOk = allWithPrev (prev: curr: let
      diff = util.abs (prev - curr);
    in
      diff >= 1 && diff <= 3)
    nums;
  in
    diffOk && (isAsc || isDesc);

  getDropouts = vals: let
    dropouts = left: right:
      if right == []
      then []
      else let
        rest = builtins.tail right;
      in
        [(left ++ rest)]
        ++ (dropouts (left ++ [(builtins.head right)]) rest);
  in
    dropouts [] vals;
in
  input: let
    records =
      map (line: map builtins.fromJSON (util.splitBy " " line))
      (util.splitBy "\n" input);

    ans =
      builtins.foldl' (total: record:
        if (isValid record) || (builtins.any isValid (getDropouts record))
        then total + 1
        else total)
      0
      records;
  in
    ans
