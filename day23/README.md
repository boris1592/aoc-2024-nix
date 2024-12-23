# Day 20 gives me flashbacks

Solving graph problems in nix is especially painful for for some reason. Here's a quick Rust solution for part 2:

```rust
use std::{
    collections::{HashMap, HashSet},
    fs::read_to_string,
    io,
};

fn max_connected(
    curr: &str,
    visited: &mut HashSet<String>,
    total: &HashSet<String>,
    graph: &HashMap<String, HashSet<String>>,
) -> Vec<String> {
    if visited.contains(curr) {
        return vec![];
    }

    visited.insert(curr.into());

    let next = total
        .intersection(graph.get(curr).unwrap())
        .map(String::from)
        .collect::<HashSet<String>>();
    let mut max_vec = vec![];

    for node in next.clone() {
        let new_vec = max_connected(&node, visited, &next, graph);

        if new_vec.len() > max_vec.len() {
            max_vec = new_vec;
        }
    }

    max_vec.push(curr.into());
    max_vec
}

fn solve(graph: &HashMap<String, HashSet<String>>) -> Vec<String> {
    graph
        .keys()
        .map(|start| {
            let mut visited = HashSet::new();
            let total = graph.get(start).unwrap();
            max_connected(start, &mut visited, total, graph)
        })
        .max_by(|a, b| a.len().cmp(&b.len()))
        .unwrap()
}

fn main() -> io::Result<()> {
    let input = read_to_string("input")?;
    let mut graph = HashMap::<String, HashSet<String>>::new();

    for pair in input
        .split('\n')
        .filter(|line| !line.is_empty())
        .map(|line| line.split('-').collect::<Vec<_>>())
    {
        let first = pair[0];
        let second = pair[1];

        match graph.get_mut(first.into()) {
            Some(set) => _ = set.insert(second.into()),
            None => _ = graph.insert(first.into(), HashSet::from([second.into()])),
        };

        match graph.get_mut(second.into()) {
            Some(set) => _ = set.insert(first.into()),
            None => _ = graph.insert(second.into(), HashSet::from([first.into()])),
        };
    }

    let mut ans = solve(&graph);
    ans.sort();
    dbg!(ans.join(","));
    Ok(())
}
```
