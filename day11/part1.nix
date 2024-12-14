let
  util = import ../util.nix;

  digits = num: builtins.stringLength (builtins.toString num);

  blink = stone: times: let
    count = digits stone;
    power = util.pow 10 (count / 2);

    ans =
      if times == 0
      then 1
      else if stone == 0
      then blink 1 (times - 1)
      else if (util.mod count 2) == 0
      then
        (blink (stone / power) (times - 1))
        + (blink (util.mod stone power) (times - 1))
      else blink (stone * 2024) (times - 1);
  in
    ans;
in
  input: let
    stones = map builtins.fromJSON (util.splitBy " " input);
    ans = builtins.foldl' (sum: stone: sum + blink stone 25) 0 stones;
  in
    ans
