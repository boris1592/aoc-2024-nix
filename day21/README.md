# I gave up once again

This time it isn't the language's fault (however I believe that nix would once again run out of memory trying to memoize this one), it's just that I've been thinking about the solution for such a long time I didn't have any mental capacity left to think functionally. So here's a part 2 solution in Rust:

```rust
use std::{collections::HashMap, fs::read_to_string, io, sync::LazyLock};

struct Keypad {
    pos: HashMap<char, (i32, i32)>,
    banned: (i32, i32),
}

static NUMPAD: LazyLock<Keypad> = LazyLock::new(|| Keypad {
    pos: HashMap::from([
        ('7', (0, 0)),
        ('8', (0, 1)),
        ('9', (0, 2)),
        ('4', (1, 0)),
        ('5', (1, 1)),
        ('6', (1, 2)),
        ('1', (2, 0)),
        ('2', (2, 1)),
        ('3', (2, 2)),
        ('0', (3, 1)),
        ('A', (3, 2)),
    ]),
    banned: (3, 0),
});

static DIRPAD: LazyLock<Keypad> = LazyLock::new(|| Keypad {
    pos: HashMap::from([
        ('^', (0, 1)),
        ('A', (0, 2)),
        ('<', (1, 0)),
        ('v', (1, 1)),
        ('>', (1, 2)),
    ]),
    banned: (0, 0),
});

fn all_paths(from: char, to: char, keypad: &Keypad) -> Vec<String> {
    let a = keypad.pos[&from];
    let b = keypad.pos[&to];

    let d_row = b.0 - a.0;
    let d_col = b.1 - a.1;

    let mid_rows = (b.0, a.1);
    let rows = (if d_row >= 0 { "v" } else { "^" }).repeat(d_row.abs() as usize);

    let mid_cols = (a.0, b.1);
    let cols = (if d_col >= 0 { ">" } else { "<" }).repeat(d_col.abs() as usize);

    let mut ans = Vec::new();

    if mid_rows != keypad.banned {
        ans.push(rows.clone() + &cols + "A");
    }

    if mid_cols != keypad.banned {
        ans.push(cols.clone() + &rows + "A");
    }

    ans
}

fn shortest(from: char, to: char, level: u8, cache: &mut HashMap<(char, char, u8), u64>) -> u64 {
    if let Some(val) = cache.get(&(from, to, level)) {
        return *val;
    }

    let ans = if level == 0 {
        all_paths(from, to, &DIRPAD)
            .iter()
            .map(String::len)
            .min()
            .unwrap() as u64
    } else {
        let paths = all_paths(from, to, &DIRPAD);
        let mut min = 1 << 63;

        for path in paths {
            let mut prev = 'A';
            let mut total = 0;

            for key in path.chars() {
                total += shortest(prev, key, level - 1, cache);
                prev = key;
            }

            min = min.min(total);
        }

        min
    };

    cache.insert((from, to, level), ans);
    ans
}

fn solve(code: &str, depth: u8) -> u64 {
    let mut cache = HashMap::new();
    let mut prev = 'A';
    let mut total = 0;

    for next in code.chars() {
        let mut min = 1 << 63;
        let paths = all_paths(prev, next, &NUMPAD);
        prev = next;

        for path in paths {
            let mut total = 0;
            let mut prev = 'A';

            for next in path.chars() {
                total += shortest(prev, next, depth, &mut cache);
                prev = next;
            }

            min = min.min(total);
        }

        total += min;
    }

    total
}

fn main() -> io::Result<()> {
    let input = read_to_string("input")?;
    let ans = input
        .split('\n')
        .filter(|line| !line.is_empty())
        .map(|code| {
            let num = code
                .chars()
                .take(code.len() - 1)
                .collect::<String>()
                .parse::<u64>()
                .unwrap();
            solve(code, 24) * num
        })
        .reduce(|acc, c| acc + c);

    dbg!(ans);
    Ok(())
}
```
