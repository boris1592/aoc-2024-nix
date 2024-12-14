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

    positions = step: map (simulate width height step) robots;

    draw = step: let
      posSet = builtins.foldl' (set: pos: set // {${builtins.toJSON pos} = true;}) {} (positions step);

      rows = builtins.genList (y:
        builtins.genList (x: let
          key = builtins.toJSON {
            inherit x;
            inherit y;
          };
          char =
            if posSet ? ${key}
            then "#"
            else ".";
        in
          char)
        width)
      height;

      image = builtins.foldl' (total: row: total + (builtins.foldl' (total: char: total + char) "" row) + "\n") "" rows;
    in
      image;

    # it only took 10 mins...
    steps = builtins.genList (step: (builtins.toJSON step) + "\n" + (draw step)) 10000;
    image = builtins.foldl' (total: image: total + image) "" steps;
  in
    builtins.toFile "output" image
