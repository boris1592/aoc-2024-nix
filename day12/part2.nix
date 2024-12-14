let
  util = import ../util.nix;

  lookup2d = row: col: field: let
    line = util.safeElemAt row field;
  in
    if line ? val
    then util.safeElemAt col line.val
    else {};

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
in
  input: let
    field = map util.chars (util.splitBy "\n" input);

    dfs = curr: visited: id: let
      key = builtins.toJSON curr;
    in
      if visited ? ${key}
      then visited
      else let
        visited' = visited // {${key} = id;};
        value = (lookup2d curr.row curr.col field).val;
        cells = neighbors curr;
      in
        builtins.foldl' (visited: {
            row,
            col,
          } @ next: let
            val = lookup2d row col field;
            nextVal = util.orDefault val "";
          in
            if nextVal == value
            then dfs next visited id
            else visited) visited'
        cells;

    groups =
      (builtins.foldl' (state: c: let
        row = c.i;
        line = c.item;
      in
        builtins.foldl' ({
          visited,
          lastId,
        }: c: let
          col = c.i;
          curr = {
            inherit row;
            inherit col;
          };
          key = builtins.toJSON curr;

          lastId' =
            if visited ? ${key}
            then lastId
            else lastId + 1;
          visited' =
            if visited ? ${key}
            then visited
            else dfs curr visited lastId';
        in {
          visited = visited';
          lastId = lastId';
        }) state (util.enumerate line)) {
        lastId = 0;
        visited = {};
      } (util.enumerate field))
      .visited;

    areas = builtins.foldl' (total: key: let
      val = builtins.toString groups.${key};
      curr =
        if total ? ${val}
        then total.${val}
        else 0;
      total' = total // {${val} = curr + 1;};
    in
      total') {} (builtins.attrNames groups);

    isCorner = group: coord: delta: let
      sameRow = builtins.toJSON {
        row = coord.row;
        col = coord.col + delta.col;
      };
      sameCol = builtins.toJSON {
        row = coord.row + delta.row;
        col = coord.col;
      };
      target = builtins.toJSON {
        row = coord.row + delta.row;
        col = coord.col + delta.col;
      };
      getGroup = key:
        if groups ? ${key}
        then groups.${key}
        else -1;

      outerCorner = getGroup sameRow != group && getGroup sameCol != group;
      innerCorner =
        getGroup sameRow
        == group
        && getGroup sameCol == group
        && getGroup target != group;
    in
      outerCorner || innerCorner;

    sides = builtins.foldl' (total: c: let
      row = c.i;
      line = c.item;
    in
      builtins.foldl' (total: c: let
        col = c.i;
        curr = {
          inherit row;
          inherit col;
        };
        group = groups.${builtins.toJSON curr};

        corners =
          builtins.foldl'
          (sum: delta:
            if isCorner group curr delta
            then sum + 1
            else sum)
          0 [
            {
              row = -1;
              col = -1;
            }
            {
              row = -1;
              col = 1;
            }
            {
              row = 1;
              col = 1;
            }
            {
              row = 1;
              col = -1;
            }
          ];

        groupStr = builtins.toString group;
        count =
          if total ? ${groupStr}
          then total.${groupStr}
          else 0;
        total' = total // {${groupStr} = count + corners;};
      in
        total') total (util.enumerate line)) {} (util.enumerate field);

    ans =
      builtins.foldl' (sum: group: sides.${group} * areas.${group} + sum) 0
      (builtins.attrNames areas);
  in
    ans
