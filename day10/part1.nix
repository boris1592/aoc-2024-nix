let
  util = import ../util.nix;

  neighbors = {
    row,
    col,
  }: [
    {
      row = row - 1;
      inherit col;
    }
    {
      inherit row;
      col = col + 1;
    }
    {
      row = row + 1;
      inherit col;
    }
    {
      inherit row;
      col = col - 1;
    }
  ];
in
  input: let
    field =
      map (line: map builtins.fromJSON (util.chars line))
      (util.splitBy "\n" input);

    height = {
      row,
      col,
    }: let
      line = builtins.elemAt field row;
      res = builtins.elemAt line col;
      inBounds =
        row
        >= 0
        && row < builtins.length field
        && col >= 0
        && col
        < builtins.length line;
    in
      if inBounds
      then res
      else -1;

    dfs = curr: visited: let
      key = builtins.toJSON curr;
      h = height curr;
      cells = neighbors curr;
      visited' = visited // {${key} = true;};

      rest =
        builtins.foldl' (state: c: let
          res = dfs c state.visited;
          h' = height c;
          state' = {
            ans = state.ans + res.ans;
            visited = res.visited;
          };
        in
          if h' == h + 1
          then state'
          else state) {
          visited = visited';
          ans = 0;
        }
        cells;
    in
      if (visited ? ${key}) || h < 0
      then {
        ans = 0;
        inherit visited;
      }
      else if h == 9
      then {
        ans = 1;
        visited = builtins.trace (builtins.toJSON visited') visited';
      }
      else rest;

    ans = builtins.foldl' (s: c: let
      row = c.i;
      line = c.item;
    in
      builtins.foldl' (sum: c: let
        col = c.i;
        h = c.item;
      in
        if h == 0
        then
          sum
          + (dfs {
            inherit row;
            inherit col;
          } {})
          .ans
        else sum) s (util.enumerate line)) 0 (util.enumerate field);
  in
    ans
