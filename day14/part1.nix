let
  util = import ../util.nix;

  simulate = width: height: steps: {
    pos,
    vel,
  }: let
    x = util.mod (pos.x + vel.x * steps) width;
    y = util.mod (pos.y + vel.y * steps) height;
  in {
    inherit x;
    inherit y;
  };
in
  input: let
    robots = map (line: let
      parts = map (part: map builtins.fromJSON (util.splitBy "," (builtins.substring 2 (-1) part))) (util.splitBy " " line);
      posArr = builtins.head parts;
      velArr = builtins.elemAt parts 1;

      pos = {
        x = builtins.head posArr;
        y = builtins.elemAt posArr 1;
      };
      vel = {
        x = builtins.head velArr;
        y = builtins.elemAt velArr 1;
      };
    in {
      inherit pos;
      inherit vel;
    }) (util.splitBy "\n" input);

    width = 101;
    height = 103;
    steps = 100;

    positions = map (simulate width height steps) robots;

    quadSet = builtins.foldl' (set: pos: let
      quadX = pos.x / (width / 2 + 1);
      quadY = pos.y / (height / 2 + 1);
      key = builtins.toJSON {
        inherit quadX;
        inherit quadY;
      };
      cnt = set.${key} or 0;
      set' = set // {${key} = cnt + 1;};
    in
      if pos.x == width / 2 || pos.y == height / 2
      then set
      else set') {}
    positions;

    ans = builtins.foldl' builtins.mul 1 (builtins.attrValues quadSet);
  in
    ans
