let
  util = import ../util.nix;
in
  input: let
    height = builtins.length (util.splitBy "\n" input);
    width = builtins.stringLength (builtins.head (util.splitBy "\n" input));
    isOk = p: p.row >= 0 && p.row < height && p.col >= 0 && p.col < width;

    antennas = builtins.foldl' (g: l: let
      row = l.i;
      line = util.chars l.item;
    in
      builtins.foldl' (g: c: let
        col = c.i;
        char = c.item;
        other = g.${char} or [];

        g' =
          if char == "."
          then g
          else
            g
            // {
              ${char} =
                [
                  {
                    inherit row;
                    inherit col;
                  }
                ]
                ++ other;
            };
      in
        g') g (util.enumerate line)) {}
    (util.enumerate (util.splitBy "\n" input));

    findAntinodes = let
      findAntinodesInner = m: a: b: let
        first = {
          row = b.row + (b.row - a.row) * m;
          col = b.col + (b.col - a.col) * m;
        };
        second = {
          row = a.row + (a.row - b.row) * m;
          col = a.col + (a.col - b.col) * m;
        };

        res =
          (
            if isOk first
            then [first]
            else []
          )
          ++ (
            if isOk second
            then [second]
            else []
          )
          ++ (
            if isOk first || isOk second
            then findAntinodesInner (m + 1) a b
            else []
          );
      in
        res;
    in
      findAntinodesInner 0;

    antinodes = builtins.foldl' (set: antennas: let
      allPoints = builtins.concatMap (a:
        builtins.concatMap (b:
          if a == b
          then []
          else findAntinodes a b)
        antennas)
      antennas;

      points = builtins.filter isOk allPoints;

      set' =
        builtins.foldl' (s: p: s // {${builtins.toJSON p} = 1;}) set points;
    in
      set') {} (builtins.attrValues antennas);

    ans = builtins.foldl' builtins.add 0 (builtins.attrValues antinodes);
  in
    ans
