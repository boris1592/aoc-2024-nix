with builtins;
with (import ../util.nix); let
  findTrios = graph:
    foldl'
    (set: node: let
      connected = attrNames (graph.${node} or {});
      interConnected =
        foldl'
        (list: node1:
          list
          ++ (map
            (node2: [node node1 node2])
            (filter
              (node2: (graph.${node1} or {}).${node2} or false)
              connected)))
        []
        connected;

      interConnected' = filter (any (str: head (chars str) == "t")) interConnected;
      keys = map (arr: toJSON (sort lessThan arr)) interConnected';
      set' = foldl' (set: key: set // {${key} = true;}) set keys;
    in
      set')
    {}
    (attrNames graph);
in
  input: let
    lines = splitBy "\n" input;
    pairs = map (splitBy "-") lines;
    graph =
      foldl'
      (
        graph: pair: let
          n1 = elemAt pair 0;
          n2 = elemAt pair 1;

          set1 = (graph.${n1} or {}) // {${n2} = true;};
          set2 = (graph.${n2} or {}) // {${n1} = true;};
          graph' =
            graph
            // {
              ${n1} = set1;
              ${n2} = set2;
            };
        in
          graph'
      )
      {}
      pairs;

    trios = findTrios graph;
    ans = length (attrNames trios);
  in
    ans
