let
  util = import ../util.nix;

  neighbors = { row, col }: [
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
in input:
let
  field = map (line: map builtins.fromJSON (util.chars line))
    (util.splitBy "\n" input);

  height = { row, col }:
    let
      line = builtins.elemAt field row;
      res = builtins.elemAt line col;
      inBounds = row >= 0 && row < builtins.length field && col >= 0 && col
        < builtins.length line;
    in if inBounds then res else -1;

  dfs = curr:
    let
      h = height curr;
      cells = neighbors curr;

      rest = builtins.foldl' (total: c:
        let
          res = dfs c;
          h' = height c;
        in if h' == h + 1 then total + res else total) 0 cells;
    in if h < 0 then 0 else if h == 9 then 1 else rest;

  ans = builtins.foldl' (s: c:
    let
      row = c.i;
      line = c.item;
    in builtins.foldl' (sum: c:
      let
        col = c.i;
        h = c.item;
      in if h == 0 then
        sum + (dfs {
          inherit row;
          inherit col;
        })
      else
        sum) s (util.enumerate line)) 0 (util.enumerate field);
in ans
