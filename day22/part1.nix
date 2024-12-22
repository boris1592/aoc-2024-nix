with builtins;
with (import ../util.nix); let
  prune = a: mod a 16777216;

  step = a: let
    a' = prune (bitXor a (a * 64));
    a'' = prune (bitXor a' (a' / 32));
    a''' = prune (bitXor a'' (a'' * 2048));
  in
    a''';

  # wanted to do recursion but from my observations nix doesn't have tail call optimisation
  # so the amount of memory required is equivalent
  stepTimes = times: a: foldl' (a: _: step a) a (genList (_: null) times);
in
  input: let
    nums = map fromJSON (splitBy "\n" input);
    ans = foldl' add 0 (map (stepTimes 2000) nums);
  in
    ans
