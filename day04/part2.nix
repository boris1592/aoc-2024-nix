let
  util = import ../util.nix;

  neighbors = { row, col }: [
    {
      row = row - 1;
      col = col - 1;
    }
    {
      row = row - 1;
      col = col + 1;
    }
    {
      row = row + 1;
      col = col + 1;
    }
    {
      row = row + 1;
      col = col - 1;
    }
  ];
in input:
let
  letters = builtins.map util.chars (util.splitBy "\n" input);

  height = builtins.length letters;
  width = builtins.length (builtins.head letters);
  isOk = { row, col }: row >= 0 && row < height && col >= 0 && col < width;

  checkXMas = { row, col }@coord:
    let
      cells = neighbors coord;
      letter = builtins.elemAt (builtins.elemAt letters row) col;
      hasA = letter == "A";

      hasX = builtins.any (offset:
        let
          target = util.chars "MMSS";

          ok = builtins.all (i:
            let
              cell = builtins.elemAt cells (util.mod (i + offset) 4);
              value =
                builtins.elemAt (builtins.elemAt letters cell.row) cell.col;

              ok = isOk cell && value == builtins.elemAt target i;
            in ok) (builtins.genList (i: i) 4);
        in ok) (builtins.genList (i: i) 4);
    in hasA && hasX;

  res = builtins.genList (row:
    builtins.genList (col:
      if checkXMas {
        inherit row;
        inherit col;
      } then
        1
      else
        0) width) height;

  ans = builtins.foldl' builtins.add 0 (builtins.concatLists res);
in ans
