let
  util = import ../util.nix;
in
  input: let
    machines = builtins.tail (builtins.foldl' (list: line: let
      first = builtins.head list;
      rest = builtins.tail list;
      vals = util.splitBy " " line;

      strToXCord = str:
        builtins.fromJSON
        (builtins.substring 2 (builtins.stringLength str - 3) str)
        + 0.0;

      strToYCord = str:
        builtins.fromJSON
        (builtins.substring 2 (builtins.stringLength str - 2) str)
        + 0.0;

      claw = {
        x = strToXCord (builtins.elemAt vals 2);
        y = strToYCord (builtins.elemAt vals 3);
      };
      prize = {
        x = strToXCord (builtins.elemAt vals 1) + 1.0e13;
        y = strToYCord (builtins.elemAt vals 2) + 1.0e13;
      };

      list' =
        if !(first ? A)
        then [{A = claw;}] ++ rest
        else if !(first ? B)
        then
          [
            {
              A = first.A;
              B = claw;
            }
          ]
          ++ rest
        else
          [
            {}
            {
              A = first.A;
              B = first.B;
              inherit prize;
            }
          ]
          ++ rest;
    in
      list') [{}] (util.splitBy "\n" input));

    findMinCost = {
      A,
      B,
      prize,
    }: let
      delta = A.x * B.y - B.x * A.y;
      delta1 = prize.x * B.y - B.x * prize.y;
      delta2 = A.x * prize.y - prize.x * A.y;
      aPushes = builtins.floor (delta1 / delta);
      bPushes = builtins.floor (delta2 / delta);
      res = {
        x = A.x * aPushes + B.x * bPushes;
        y = A.y * aPushes + B.y * bPushes;
      };

      ans =
        if res == prize
        then aPushes * 3 + bPushes
        else 0;
    in
      ans;

    ans = builtins.foldl' (total: curr: total + findMinCost curr) 0 machines;
  in
    ans
