let
  util = import ../util.nix;

  allWithPrev = fn: nums:
    (builtins.foldl' ({ prev, ans }:
      curr: {
        prev = curr;
        ans = (ans && (fn prev curr));
      }) {
        prev = (builtins.head nums);
        ans = true;
      } (builtins.tail nums)).ans;

  isValid = nums:
    let
      isAsc = (allWithPrev (prev: curr: curr >= prev) nums);
      isDesc = (allWithPrev (prev: curr: curr <= prev) nums);

      diffOk = (allWithPrev (prev: curr:
        let diff = util.abs (prev - curr);
        in diff >= 1 && diff <= 3) nums);
    in diffOk && (isAsc || isDesc);
in input:
let
  records = map (line: map builtins.fromJSON (util.splitBy " " line))
    (util.splitBy "\n" input);

  ans = builtins.foldl'
    (total: record: if (isValid record) then total + 1 else total) 0 records;
in ans
