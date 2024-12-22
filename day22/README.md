# I gave up again

Nix runs out of memory because there's no way to store sequences' running total without clonning everything. I could probably do it in Haskell utilizing the State monad but I'm too lazy to install haskell on my desktop, so here is a rust solution:

```rust
use std::{
    collections::{HashMap, HashSet},
    fs::read_to_string,
    io,
};

fn prune(num: i64) -> i64 {
    num % (1 << 24)
}

fn step(num: i64) -> i64 {
    let num1 = prune(num ^ (num * 64));
    let num2 = prune(num1 ^ (num1 / 32));
    let num3 = prune(num2 ^ (num2 * 2048));
    num3
}

fn solve(nums: &[i64]) -> i64 {
    let mut seqs = HashMap::<Vec<i64>, (i64, HashSet<usize>)>::new();

    for i in 0..nums.len() {
        let mut prev = nums[i];
        let mut seq = vec![];

        for _ in 0..2000 {
            let next = step(prev);
            let price = next % 10;

            seq.push(price - (prev % 10));
            prev = next;

            if seq.len() > 4 {
                seq.remove(0);
            }

            match seqs.get_mut(&seq) {
                Some(acc) => {
                    if acc.1.contains(&i) {
                        continue;
                    }

                    acc.0 += price;
                    acc.1.insert(i);
                }
                None => _ = seqs.insert(seq.clone(), (price, HashSet::from([i]))),
            };
        }
    }

    seqs.iter().max_by(|x, y| x.1 .0.cmp(&y.1 .0)).unwrap().1 .0
}

fn main() -> io::Result<()> {
    let input = read_to_string("input")?;
    let nums = input
        .split('\n')
        .map(|str| str.parse::<i64>().unwrap())
        .collect::<Vec<_>>();

    let ans = solve(&nums);
    dbg!(ans);
    Ok(())
}
```
