with builtins;
with (import ../util.nix); let
  point = row: col: {
    inherit row;
    inherit col;
  };

  numpad = {
    "7" = point 0 0;
    "8" = point 0 1;
    "9" = point 0 2;
    "4" = point 1 0;
    "5" = point 1 1;
    "6" = point 1 2;
    "1" = point 2 0;
    "2" = point 2 1;
    "3" = point 2 2;
    "0" = point 3 1;
    "A" = point 3 2;
    disallowed = point 3 0;
  };

  dirpad = {
    "^" = point 0 1;
    "A" = point 0 2;
    "<" = point 1 0;
    "v" = point 1 1;
    ">" = point 1 2;
    disallowed = point 0 0;
  };

  buildPaths = sequence: keypad: {
    row,
    col,
  }: let
    next = head sequence;
    target = keypad.${next};

    vert =
      if target.row > row
      then "v"
      else "^";
    hor =
      if target.col > col
      then ">"
      else "<";

    rows = genList (_: vert) (abs (target.row - row));
    cols = genList (_: hor) (abs (target.col - col));
    rem = buildPaths (tail sequence) keypad target;

    firstRows = map (r: rows ++ cols ++ ["A"] ++ r) rem;
    firstCols = map (r: cols ++ rows ++ ["A"] ++ r) rem;

    midFirstRows = {
      row = target.row;
      inherit col;
    };
    midFirstCols = {
      inherit row;
      col = target.col;
    };

    firstRows' =
      if midFirstRows == keypad.disallowed
      then []
      else firstRows;
    firstCols' =
      if midFirstCols == keypad.disallowed
      then []
      else firstCols;
  in
    if sequence == []
    then [[]]
    else if firstRows' == firstCols'
    then firstRows'
    else firstRows' ++ firstCols';

  shortestPath = a: b:
    minBy
    length
    (concatMap
      (p: buildPaths p dirpad dirpad.${"A"})
      (concatMap
        (p: buildPaths p dirpad dirpad.${"A"})
        (buildPaths [b] numpad numpad.${a})));

  memo =
    foldl'
    (set: from: let
      val =
        foldl'
        (set: to: set // {${to} = shortestPath from to;})
        {}
        (attrNames numpad);
    in
      set // {${from} = val;})
    {}
    (attrNames numpad);

  generateForPass = prev: password: let
    first = head password;
    rest = tail password;

    p = memo.${prev}.${first};
    p' = p ++ (generateForPass first rest);
  in
    if password == []
    then []
    else p';
in
  input: let
    toNum = let
      inner = total: str: let
        first = substring 0 1 str;
        rest = substring 1 (-1) str;
      in
        if str == "" || str == "A"
        then total
        else inner (total * 10 + (fromJSON first)) rest;
    in
      inner 0;

    lines = splitBy "\n" input;
    nums = map toNum lines;

    lengths = map (p: length (generateForPass "A" p)) (map chars lines);
    total =
      foldl' (total: c: total + c.a * c.b)
      0 (zip lengths nums);
  in
    total
