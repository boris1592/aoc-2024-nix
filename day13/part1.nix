let util = import ../util.nix;
in input:
let
  machines = builtins.tail (builtins.foldl' (list: line:
    let
      first = builtins.head list;
      rest = builtins.tail list;
      vals = util.splitBy " " line;

      strToXCord = str:
        builtins.fromJSON
        (builtins.substring 2 (builtins.stringLength str - 3) str);

      strToYCord = str:
        builtins.fromJSON
        (builtins.substring 2 (builtins.stringLength str - 2) str);

      claw = {
        x = strToXCord (builtins.elemAt vals 2);
        y = strToYCord (builtins.elemAt vals 3);
      };
      prize = {
        x = strToXCord (builtins.elemAt vals 1);
        y = strToYCord (builtins.elemAt vals 2);
      };

      list' = if !(first ? A) then
        [{ A = claw; }] ++ rest
      else if !(first ? B) then
        [{
          A = first.A;
          B = claw;
        }] ++ rest
      else
        [
          { }
          {
            A = first.A;
            B = first.B;
            inherit prize;
          }
        ] ++ rest;
    in list') [ { } ] (util.splitBy "\n" input));

  findMinCost = aPushes:
    { A, B, prize }@arg:
    let
      rem = prize.x - A.x * aPushes;
      bPushes = rem / B.x;
      totalX = A.x * aPushes + B.x * bPushes;
      totalY = A.y * aPushes + B.y * bPushes;

      ans = if totalX == prize.x && totalY == prize.y then
        aPushes * 3 + bPushes
      else if rem > 0 then
        findMinCost (aPushes + 1) arg
      else 0;
    in ans;

  ans = builtins.foldl' (total: curr: total + findMinCost 0 curr) 0 machines;
in ans
