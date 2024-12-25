with builtins;
with (import ../util.nix); let
  getHeights = entry:
    foldl'
    (set: line:
      foldl'
      (set: c: let
        char = c.item;
        col = toJSON c.i;
        cnt = set.${col} or 0;
      in
        set
        // {
          ${col} =
            cnt
            + (
              if char == "#"
              then 1
              else 0
            );
        })
      set
      (enumerate (chars line)))
    {}
    (splitBy "\n" entry);

  count = lock: keys:
    length
    (filter
      (key:
        all
        (col: key.${col} + lock.${col} <= 7)
        (attrNames lock))
      keys);
in
  input: let
    entries = splitBy "\n\n" input;
    locks = map getHeights (filter (entry: head (splitBy "\n" entry) == "#####") entries);
    keys = map getHeights (filter (entry: head (splitBy "\n" entry) == ".....") entries);
    ans = foldl' (total: lock: total + count lock keys) 0 locks;
  in
    ans
