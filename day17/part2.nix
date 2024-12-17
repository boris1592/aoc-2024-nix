let
  util = import ../util.nix;

  comboOperand = op: {
    a,
    b,
    c,
    ...
  }:
    if op < 4
    then op
    else if op == 4
    then a
    else if op == 5
    then b
    else if op == 6
    then c
    else op;

  step = program: {
    key,
    instruction,
    a,
    b,
    c,
    output,
  } @ state: let
    opcode = builtins.elemAt program instruction;
    literal = builtins.elemAt program (instruction + 1);
    combo = comboOperand literal state;

    state' =
      (state
        // {
          key = key + 1;
          instruction = instruction + 2;
        })
      // (
        if opcode == 0 # adv
        then {a = a / (util.pow 2 combo);}
        else if opcode == 1 # bxl
        then {b = builtins.bitXor b literal;}
        else if opcode == 2 # bst
        then {b = util.mod combo 8;}
        else if opcode == 3 # jnz
        then
          (
            if a == 0
            then {}
            else {instruction = literal;}
          )
        else if opcode == 4 # bxc
        then {b = builtins.bitXor b c;}
        else if opcode == 5 # out
        then {output = output ++ [(util.mod combo 8)];}
        else if opcode == 6 # bdv
        then {b = a / (util.pow 2 combo);}
        else if opcode == 7 # cdv
        then {c = a / (util.pow 2 combo);}
        else {}
      );
  in
    state';

  simulate = program: {
    a,
    b,
    c,
  }: let
    res = builtins.genericClosure {
      startSet = [
        {
          key = 0;
          instruction = 0;
          inherit a;
          inherit b;
          inherit c;
          output = [];
        }
      ];
      operator = {instruction, ...} @ state:
        if instruction < (builtins.length program)
        then [(step program state)]
        else [];
    };
  in
    (builtins.elemAt res (builtins.length res - 1)).output;

  possibleA = program: b: c: let
    inner = total: let
      ans = builtins.concatMap (
        a: let
          output = simulate program {
            inherit a;
            inherit b;
            inherit c;
          };

          len = builtins.length output;
          target = index: builtins.elemAt program (builtins.length program - len + index);
          out = builtins.elemAt output;
          isOk = builtins.all (i: target i == out i) (builtins.genList (i: i) len);
        in
          if isOk && a > 0
          then
            if len == builtins.length program
            then [a]
            else inner a
          else []
      ) (builtins.genList (i: total * 8 + i) 8);
    in
      ans;
  in
    inner 0;
in
  input: let
    lines = util.splitBy "\n" input;
    b = builtins.fromJSON (builtins.elemAt (util.splitBy " " (builtins.elemAt lines 1)) 2);
    c = builtins.fromJSON (builtins.elemAt (util.splitBy " " (builtins.elemAt lines 2)) 2);
    program = map builtins.fromJSON (util.splitBy "," (builtins.elemAt (util.splitBy " " (builtins.elemAt lines 3)) 1));

    possible = possibleA program b c;
    min = builtins.foldl' (min: a:
      if a < min
      then a
      else min) (builtins.head possible) (builtins.tail possible);
  in
    min
