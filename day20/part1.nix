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

  inBounds = {
    width,
    height,
    ...
  }: {
    row,
    col,
  }:
    row >= 0 && row < height && col >= 0 && col < width;

  bfs = field: start: let
    res = builtins.genericClosure {
      startSet = [
        {
          key = 0;
          queue = [start];
          dist = {${builtins.toJSON start} = 0;};
        }
      ];

      operator = {
        key,
        queue,
        dist,
      }: let
        curr = builtins.head queue;
        d = dist.${builtins.toJSON curr};

        next =
          builtins.filter
          (coord: let
            key = builtins.toJSON coord;
            visited = dist ? ${key};
            isTrack = field.${key} or false;
            isOk = inBounds field coord;
          in
            isOk && isTrack && !visited)
          (neighbors curr);

        dist' =
          builtins.foldl'
          (dist: coord: dist // {${builtins.toJSON coord} = d + 1;})
          dist
          next;

        state' = {
          key = key + 1;
          dist = dist';
          queue = (builtins.tail queue) ++ next;
        };
      in
        if queue == []
        then []
        else [state'];
    };

    last = builtins.elemAt res ((builtins.length res) - 1);
  in
    last.dist;

  findShortest = curr: dists:
    builtins.foldl'
    (min: cell: let
      d = dists.${builtins.toJSON cell} or min;
    in
      if min == null || d < min
      then d
      else min)
    null
    (neighbors curr);
in
  input: let
    lines = util.splitBy "\n" input;

    cells =
      builtins.foldl'
      (field: l: let
        row = l.i;
        line = l.item;
      in
        builtins.foldl'
        (field: c: let
          col = c.i;
          char = c.item;
          coord = {
            inherit row;
            inherit col;
          };
          key = builtins.toJSON coord;
        in
          if char == "."
          then field // {${key} = true;}
          else if char == "S"
          then
            field
            // {
              start = coord;
              ${key} = true;
            }
          else if char == "E"
          then
            field
            // {
              end = coord;
              ${key} = true;
            }
          else field)
        field
        (util.enumerate (util.chars line)))
      {}
      (util.enumerate lines);

    field =
      cells
      // {
        height = builtins.length lines;
        width = builtins.stringLength (builtins.head lines);
      };

    distS = bfs field field.start;
    distE = bfs field field.end;
    targetDist = distS.${builtins.toJSON field.end};

    saved =
      builtins.foldl'
      (saved: c1: let
        q1 = findShortest c1 distS;

        saved' =
          builtins.foldl'
          (saved: c2: let
            q2 = distE.${builtins.toJSON c2} or null;
            total = q1 + q2 + 2;
            savedTime = targetDist - total;
            key = builtins.toJSON {
              inherit c1;
              inherit c2;
            };
          in
            if field ? ${builtins.toJSON c2} && q1 != null && q2 != null && savedTime > 0
            then saved // {${key} = savedTime;}
            else saved)
          saved
          (neighbors c1);
      in
        saved')
      {}
      (builtins.filter (c: !(field ? ${builtins.toJSON c}))
        (builtins.concatLists
          (builtins.genList
            (row:
              builtins.genList
              (col: {
                inherit row;
                inherit col;
              })
              field.width)
            field.height)));

    ans =
      builtins.foldl'
      (total: key: let
        save = saved.${key};
      in
        if save >= 100
        then total + 1
        else total)
      0
      (builtins.attrNames saved);
  in
    ans
