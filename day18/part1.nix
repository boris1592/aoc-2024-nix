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

  height = 71;
  width = 71;
  count = 1024;

  isOk = {
    row,
    col,
  }:
    row >= 0 && row < height && col >= 0 && col < width;

  bfs = start: obstacles: let
    res = builtins.genericClosure {
      startSet = [
        {
          key = 1;
          dist = {${builtins.toJSON start} = 0;};
          queue = [start];
        }
      ];

      operator = {
        key,
        dist,
        queue,
      }: let
        curr = builtins.head queue;
        d = dist.${builtins.toJSON curr};

        next = builtins.filter (
          coord: let
            ok = isOk coord;
            key = builtins.toJSON coord;
            obstacle = obstacles ? ${key};
            visited = dist ? ${key};
          in
            ok && !obstacle && !visited
        ) (neighbors curr);

        dist' = builtins.foldl' (dist: coord: dist // {${builtins.toJSON coord} = d + 1;}) dist next;
        queue' = (builtins.tail queue) ++ next;
      in
        if queue == []
        then []
        else [
          {
            key = key + 1;
            dist = dist';
            queue = queue';
          }
        ];
    };

    last = builtins.elemAt res ((builtins.length res) - 1);
  in
    last;
in
  input: let
    obstacles = builtins.foldl' (set: l: let
      index = l.i;
      line = l.item;

      nums = map builtins.fromJSON (util.splitBy "," line);
      coord = {
        row = builtins.elemAt nums 0;
        col = builtins.elemAt nums 1;
      };
      set' = set // {${builtins.toJSON coord} = true;};
    in
      if index < count
      then set'
      else set) {} (util.enumerate (util.splitBy "\n" input));

    res =
      bfs {
        row = 0;
        col = 0;
      }
      obstacles;

    dist =
      res
      .dist
      .${
        builtins.toJSON {
          row = width - 1;
          col = width - 1;
        }
      };
  in
    dist
