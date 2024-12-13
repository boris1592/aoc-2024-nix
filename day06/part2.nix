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

  stepKey = pos: dir:
    builtins.toJSON {
      inherit pos;
      inherit dir;
    };

  traverse = field:
    builtins.genericClosure {
      startSet = [{
        key = 1;
        pos = field.start;
        direction = 0;
        visited = { };
      }];

      operator = { key, pos, direction, visited }@state:
        let
          next = step pos direction;
          visKey = stepKey pos direction;
          state' = state // {
            key = key + 1;
            visited = visited // { ${visKey} = true; };
          };
        in if !(isOk next) || (visited ? ${visKey}) then
          [ ]
        else if field ? ${builtins.toJSON next} then
          [ (state' // { direction = util.mod (direction + 1) 4; }) ]
        else
          [ (state' // { pos = next; }) ];
    };

  stepSet = builtins.foldl'
    (vis: { pos, ... }: vis // { ${builtins.toJSON pos} = true; }) { }
    (traverse field);

  obstacles = builtins.filter (key:
    let
      # trace to see the progress since even my zig solution took 1 minute
      # upd: this one took 10 mins and 2 gigs of ram at max
      #
      # this 10x increase is actually pretty impressive for a purely
      # functional language designed for completely different purposes
      steps = traverse (field // { ${builtins.trace key key} = true; });
      hasLoop = builtins.any
        ({ pos, direction, visited, ... }: visited ? ${stepKey pos direction})
        steps;
    in hasLoop) (builtins.attrNames stepSet);

  ans = builtins.length obstacles;
in ans
