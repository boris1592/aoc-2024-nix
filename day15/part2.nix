let
  util = import ../util.nix;

  step = move: {
    row,
    col,
  }:
    if move == "^"
    then {
      row = row - 1;
      inherit col;
    }
    else if move == ">"
    then {
      inherit row;
      col = col + 1;
    }
    else if move == "v"
    then {
      row = row + 1;
      inherit col;
    }
    else if move == "<"
    then {
      inherit row;
      col = col - 1;
    }
    else {};

  posBox = dir: coord: let
    next = step dir coord;
  in
    if dir == "v" || dir == "^"
    then [(next // {col = next.col - 1;}) next]
    else if dir == ">"
    then [next]
    else if dir == "<"
    then [(next // {col = next.col - 1;})]
    else [];

  boxCoords = field: dir: coord: let
    positions = posBox dir coord;
    boxes = builtins.filter (pos: let
      key = builtins.toJSON pos;
    in
      field.${key} or "" == "box")
    positions;

    boxes' = builtins.concatMap (pos: let
      next =
        if dir == "^" || dir == "v"
        then [pos (pos // {col = pos.col + 1;})]
        else if dir == ">"
        then [(pos // {col = pos.col + 1;})]
        else [pos];
    in
      builtins.concatMap (boxCoords field dir) next)
    boxes;
  in
    boxes ++ boxes';

  touchesWall = field: dir: coords: let
    toCheck = builtins.concatMap (pos: let
      pos' = pos // {col = pos.col + 1;};
    in [(step dir pos) (step dir pos')])
    coords;
  in
    builtins.any (pos: let
      key = builtins.toJSON pos;
      ok = field.${key} or "" == "wall";
    in
      ok)
    toCheck;
in
  input: let
    field = builtins.foldl' (f: l: let
      row = l.i;
      line = l.item;

      f' = builtins.foldl' (field: c: let
        col = c.i;
        char = c.item;

        coord = {
          inherit row;
          col = col * 2;
        };
        coord' = coord // {col = coord.col + 1;};

        key = builtins.toJSON coord;
        key' = builtins.toJSON coord';

        field' =
          field
          // (
            if char == "#"
            then {
              ${key} = "wall";
              ${key'} = "wall";
            }
            else if char == "O"
            then {${key} = "box";}
            else if char == "@"
            then {pos = coord;}
            else {}
          );
      in
        field')
      f (util.enumerate (util.chars line));
    in
      if builtins.substring 0 1 line == "#"
      then f'
      else f) {} (util.enumerate (util.splitBy "\n" input));

    moves =
      builtins.concatMap
      util.chars
      (builtins.filter
        (line: builtins.substring 0 1 line != "#")
        (util.splitBy "\n" input));

    steps = builtins.genericClosure {
      startSet = [
        {
          key = 0;
          inherit field;
        }
      ];
      operator = {
        key,
        field,
      }: let
        dir = builtins.elemAt moves key;
        boxes = boxCoords field dir field.pos;
        shouldStay = (field.${builtins.toJSON (step dir field.pos)} or "" == "wall") || touchesWall field dir boxes;

        movedBoxes =
          (builtins.foldl' (set: box:
            set // {${builtins.toJSON box} = "";}) {}
          boxes)
          // (builtins.foldl' (set: box:
            set // {${builtins.toJSON (step dir box)} = "box";}) {}
          boxes);

        field' =
          if shouldStay
          then field
          else
            field
            // movedBoxes
            // {pos = step dir field.pos;};
      in
        if key >= builtins.length moves
        then []
        else [
          {
            key = key + 1;
            field = field';
          }
        ];
    };

    field' = (builtins.elemAt steps (builtins.length moves)).field;
    boxes = builtins.filter (name: field'.${name} or "" == "box") (builtins.attrNames field');
    total = builtins.foldl' (total: key: let pos = builtins.fromJSON key; in total + pos.row * 100 + pos.col) 0 boxes;
  in
    total
