let
  util = import ../util.nix;

  step = { row, col }:
    builtins.elemAt [
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
  height = builtins.length (util.splitBy "\n" input);
  width = builtins.stringLength (builtins.head (util.splitBy "\n" input));
  isOk = { row, col }: row >= 0 && row < height && col >= 0 && col < width;

  field = builtins.foldl' (field: l:
    let
      row = l.i;
      line = l.item;
    in builtins.foldl' (field: c:
      let
        col = c.i;
        char = c.item;

        coord = {
          inherit row;
          inherit col;
        };
        key = builtins.toJSON coord;

        field' = if char == "#" then
          field // { ${key} = true; }
        else if char == "^" then
          field // { start = coord; }
        else
          field;
      in field') field (util.enumerate (util.chars line))) { }
    (util.enumerate (util.splitBy "\n" input));

  steps = builtins.genericClosure {
    startSet = [{
      key = 1;
      pos = field.start;
      direction = 0;
    }];

    operator = { key, pos, direction }@state:
      let
        next = step pos direction;
        state' = state // { key = key + 1; };
      in if !(isOk next) then
        [ ]
      else if field ? ${builtins.toJSON next} then
        [ (state' // { direction = util.mod (direction + 1) 4; }) ]
      else
        [ (state' // { pos = next; }) ];
  };

  stepSet =
    builtins.foldl' (vis: { pos, ... }: vis // { ${builtins.toJSON pos} = 1; })
    { } steps;

  ans = builtins.foldl' builtins.add 0 (builtins.attrValues stepSet);
in ans
