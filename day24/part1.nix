with builtins;
with (import ../util.nix); let
  eval = key: exprs: let
    expr = exprs.${key};

    left = eval expr.left exprs;
    right = eval expr.right exprs;

    calc =
      if expr.op == "AND"
      then left && right
      else if expr.op == "OR"
      then left || right
      else left != right;
  in
    if expr ? const
    then expr.const
    else calc;

  findNum = exprs: let
    vals = map (name: [name (eval name exprs)]) (filter (name: substring 0 1 name == "z") (attrNames exprs));
    sorted = sort (a: b: lessThan (head b) (head a)) vals;
    ans =
      foldl'
      (total: val:
        total
        * 2
        + (
          if elemAt val 1
          then 1
          else 0
        ))
      0
      sorted;
  in
    ans;
in
  input: let
    exprs =
      listToAttrs
      (map
        (line: let
          words = splitBy " " line;

          name =
            if length words == 2
            then substring 0 3 (head words)
            else elemAt words 4;

          value =
            if length words == 2
            then {const = elemAt words 1 == "1";}
            else {
              left = elemAt words 0;
              op = elemAt words 1;
              right = elemAt words 2;
            };
        in {inherit name value;})
        (splitBy "\n" input));
  in
    findNum exprs
