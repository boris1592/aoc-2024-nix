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
in
  input: let
    lines = util.splitBy "\n" input;
    a = builtins.fromJSON (builtins.elemAt (util.splitBy " " (builtins.elemAt lines 0)) 2);
    b = builtins.fromJSON (builtins.elemAt (util.splitBy " " (builtins.elemAt lines 1)) 2);
    c = builtins.fromJSON (builtins.elemAt (util.splitBy " " (builtins.elemAt lines 2)) 2);
    program = map builtins.fromJSON (util.splitBy "," (builtins.elemAt (util.splitBy " " (builtins.elemAt lines 3)) 1));

    result = builtins.genericClosure {
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

    finalState = builtins.elemAt result (builtins.length result - 1);
    output = builtins.foldl' (total: num: total + (builtins.toJSON num) + ",") "" finalState.output;
  in
    output
