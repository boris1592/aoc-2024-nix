# Another rust excuse

Initially I decided to draw this thing using graphviz because I hoped that this thing would be just a simple ripple carry adder (which it thankfully was). I generated a dot file with nix but it wasn't so obvious where the errors were because of the way graphviz decided to plase the verticies relative to each other. I didn't want to fiddle with graphviz and try to make it render things in a specific order so I thought that most of the swaps would produce a loop (a terrible underestimate) so a brute force solution would be sufficient... it wasn't... Since it would obviously take forever with nix I chose rust for that.

After the expected failure I finally decided to refresh my knowledge on how exactly a binary adder should be arranged to try and find the solution programmatically. Thanks to [this](https://www.reddit.com/r/adventofcode/comments/1hla5ql/2024_day_24_part_2_a_guide_on_the_idea_behind_the) awesome post it didn't take another 3 hours. Since the brute force rust solution already had the required parsing code and I was pretty exhausted after the other failed attempts I decided to do it in rust again. Here's a final rust solution:

```rust
use std::{
    collections::{HashMap, HashSet},
    fs::read_to_string,
    io,
};

#[derive(PartialEq, Eq)]
enum Operation {
    And,
    Or,
    Xor,
}

enum Node {
    Constant(()),
    Operation(String, Operation, String),
}

fn parse(text: &str) -> HashMap<String, Node> {
    text.split("\n")
        .filter(|line| !line.is_empty())
        .map(|line| {
            if line.contains(": ") {
                let [name, _] = line.split(": ").collect::<Vec<_>>().try_into().unwrap();
                (name.into(), Node::Constant(()))
            } else {
                let mut it = line.split(" -> ");
                let expr = it.next().unwrap();
                let [left, op, right] = expr.split(" ").collect::<Vec<_>>().try_into().unwrap();
                let out = it.next().unwrap();

                (
                    out.into(),
                    Node::Operation(
                        left.into(),
                        match op {
                            "AND" => Operation::And,
                            "OR" => Operation::Or,
                            "XOR" => Operation::Xor,
                            _ => unreachable!(),
                        },
                        right.into(),
                    ),
                )
            }
        })
        .collect()
}

fn has_input(name: &str, op: Operation, tree: &HashMap<String, Node>) -> bool {
    tree.values()
        .filter_map(|node| match node {
            Node::Operation(l, check, r) => {
                if op == *check {
                    Some((l, r))
                } else {
                    None
                }
            }
            _ => None,
        })
        .any(|(l, r)| l == name || r == name)
}

fn solve(tree: &HashMap<String, Node>) -> String {
    let mut res: HashSet<String> = HashSet::new();

    for (key, node) in tree {
        if key.starts_with("z") {
            match node {
                Node::Operation(_, Operation::Xor, _) => (),
                _ => {
                    if key.ends_with("45") {
                    } else {
                        _ = res.insert(key.into());
                    }
                }
            }
        } else {
            match node {
                Node::Operation(l, Operation::Xor, r) => match tree[l] {
                    Node::Operation(_, Operation::Xor, _) => _ = res.insert(key.into()),
                    _ => match tree[r] {
                        Node::Operation(_, Operation::Xor, _) => _ = res.insert(key.into()),
                        _ => (),
                    },
                },
                _ => (),
            }

            match node {
                Node::Operation(l, Operation::Xor, r) => {
                    if ((l.starts_with("x") && r.starts_with("y"))
                        || (l.starts_with("y") && r.starts_with("x")))
                        && (l != "x00" && r != "x00" && l != "y00" && r != "y00")
                        && !(has_input(key, Operation::Xor, tree))
                    {
                        _ = res.insert(key.into());
                    } else {
                    }
                }
                Node::Operation(l, Operation::And, r) => {
                    if (l != "x00" && r != "x00" && l != "y00" && r != "y00")
                        && !has_input(key, Operation::Or, tree)
                    {
                        _ = res.insert(key.into());
                    } else {
                    }
                }
                _ => (),
            }
        }
    }

    let mut vec = res.into_iter().collect::<Vec<_>>();
    vec.sort();
    vec.join(",")
}

fn main() -> io::Result<()> {
    let input = read_to_string("input")?;
    let tree = parse(&input);

    let ans = solve(&tree);
    dbg!(ans);

    Ok(())
}
```
