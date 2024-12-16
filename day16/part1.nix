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

  extractMin = nodes: dist: let
    first = builtins.head nodes;
    rest = builtins.tail nodes;

    min =
      builtins.foldl' (acc: node: let
        key = builtins.toJSON node;
        d = dist.${key};
        acc' =
          if d <= acc.d
          then {
            inherit d;
            inherit node;
          }
          else acc;
      in
        acc')
      {
        node = first;
        d = dist.${builtins.toJSON first};
      }
      rest;

    nodes' = builtins.filter (node: node != min.node) nodes;
  in {
    node = min.node;
    nodes = nodes';
  };

  djikstra = start: field: let
    res = builtins.genericClosure {
      startSet = [
        rec {
          key = 0;

          nodes = [
            {
              coord = start;
              dir = 1;
            }
          ];

          dist = builtins.listToAttrs (
            builtins.map (node: let
              key = builtins.toJSON node;
            in {
              name = key;
              value = 0;
            })
            nodes
          );
        }
      ];

      operator = {
        key,
        dist,
        nodes,
      }: let
        curr = extractMin nodes dist;
        nodeDist = dist.${builtins.toJSON curr.node};

        state' =
          builtins.foldl' (
            {
              nodes,
              dist,
            } @ state: n: let
              dir = n.i;
              coord = n.item;
              node = {
                inherit dir;
                inherit coord;
              };
              key = builtins.toJSON node;
              currDist = dist.${key};

              newDist =
                nodeDist
                + 1
                + (
                  if dir == curr.node.dir
                  then 0
                  else 1000
                );

              state' =
                if (!(dist ? ${key}) || newDist < currDist) && (field.${builtins.toJSON coord} or false)
                then {
                  dist = dist // {${key} = newDist;};
                  nodes = nodes ++ [node];
                }
                else state;
            in
              state'
          )
          {
            nodes = curr.nodes;
            inherit dist;
          }
          (util.enumerate (neighbors curr.node.coord));
      in
        if nodes == []
        then []
        else [(state' // {key = key + 1;})];
    };

    last = builtins.elemAt res ((builtins.length res) - 1);
  in
    last.dist;
in
  input: let
    field =
      builtins.foldl' (
        field: l: let
          row = l.i;
          line = l.item;
        in
          builtins.foldl' (field: c: let
            col = c.i;
            char = c.item;
            coord = {
              inherit row;
              inherit col;
            };
            key = builtins.toJSON coord;

            field' =
              if char == "."
              then field // {${key} = true;}
              else if char == "S"
              then field // {start = coord;}
              else if char == "E"
              then
                field
                // {
                  end = coord;
                  ${key} = true;
                }
              else field;
          in
            field')
          field
          (util.enumerate (util.chars line))
      )
      {}
      (util.enumerate (util.splitBy "\n" input));

    dists = djikstra field.start field;
    keys = builtins.filter (
      key: let node = builtins.fromJSON key; in node.coord == field.end
    ) (builtins.attrNames dists);
    endDists = map (key: dists.${key}) keys;
  in
    endDists
