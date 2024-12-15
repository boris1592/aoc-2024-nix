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
          inherit col;
        };
        key = builtins.toJSON coord;

        field' =
          field
          // (
            if char == "#"
            then {${key} = "wall";}
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

    firstFree = field: pos: dir: let
      key = builtins.toJSON pos;
      type = field.${key} or "";
    in
      if type == "wall"
      then false
      else if type == "box"
      then firstFree field (step dir pos) dir
      else pos;

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
        next = step dir field.pos;
        attr = builtins.toJSON next;
        f = firstFree field next dir;
        fAttr = builtins.toJSON f;

        field' =
          field
          // (
            if f == false
            then {}
            else if next == f
            then {pos = next;}
            else {
              ${attr} = "";
              ${fAttr} = "box";
              pos = next;
            }
          );
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
