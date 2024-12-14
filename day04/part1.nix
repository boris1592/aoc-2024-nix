let
  util = import ../util.nix;

  getLine = delta: i: {
    row,
    col,
  }: {
    row = row + delta.row * i;
    col = col + delta.col * i;
  };

  deltas = builtins.concatMap (row:
    builtins.concatMap (col:
      if row == 0 && col == 0
      then []
      else [
        {
          inherit row;
          inherit col;
        }
      ]) [(-1) 0 1]) [(-1) 0 1];
in
  input: let
    letters = builtins.map util.chars (util.splitBy "\n" input);

    height = builtins.length letters;
    width = builtins.length (builtins.head letters);
    isOk = {
      row,
      col,
    }:
      row >= 0 && row < height && col >= 0 && col < width;

    checkWord = delta: coord:
      builtins.all ({
        i,
        item,
      }: let
        curr = getLine delta i coord;
        letter = builtins.elemAt (builtins.elemAt letters curr.row) curr.col;
        ok = isOk curr && item == letter;
      in
        ok) (util.enumerate (util.chars "XMAS"));

    sumWords = coord:
      builtins.foldl'
      (total: delta:
        total
        + (
          if checkWord delta coord
          then 1
          else 0
        ))
      0
      deltas;

    res = builtins.genList (row:
      builtins.genList (col:
        sumWords {
          inherit row;
          inherit col;
        })
      width)
    height;

    ans = builtins.foldl' builtins.add 0 (builtins.concatLists res);
  in
    ans
