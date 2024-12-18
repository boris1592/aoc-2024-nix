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

  # the input should've been larger so that
  # boring BFS would not be feasible...
  connected = obstacles: start: end: let
    res = bfs start obstacles;
    ok = res.dist ? ${builtins.toJSON end};
  in
    ok;
in
  input: let
    obstacles =
      builtins.foldl' (
        {
          obstacles,
          ok,
          first,
        }: line: let
          nums = map builtins.fromJSON (util.splitBy "," line);
          coord = {
            row = builtins.elemAt nums 0;
            col = builtins.elemAt nums 1;
          };

          obstacles' = obstacles // {${builtins.toJSON coord} = true;};
          ok' =
            connected obstacles' {
              row = 0;
              col = 0;
            } {
              row = height - 1;
              col = width - 1;
            };
        in {
          obstacles = obstacles';
          ok = ok';

          first =
            if !ok' && ok
            then coord
            else first;
        }
      ) {
        obstacles = {};
        ok = true;
        first = {};
      } (util.splitBy "\n" input);

    ans = obstacles.first;
  in
    ans
