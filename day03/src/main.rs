use std::{
    collections::{HashMap, HashSet},
    ops::Range,
};

fn is_special(c: char) -> bool {
    c != '.'
}

fn is_surrounded_by_at_least_one_special_character(
    char_map: &Vec<Vec<char>>,
    span: (usize, Range<usize>),
) -> bool {
    let (y, xrange) = span;

    let start = xrange.start.checked_sub(1).unwrap_or(0);

    let end = if xrange.end != char_map[0].len() {
        xrange.end + 1
    } else {
        xrange.end
    };

    // ....
    // CXX.
    // ....
    if xrange.start != 0 {
        if is_special(char_map[y][xrange.start - 1]) {
            return true;
        }
    }

    // ....
    // .XXC
    // ....
    if xrange.end != char_map[0].len() {
        if is_special(char_map[y][xrange.end]) {
            return true;
        }
    }

    // CCCC
    // .XX.
    // ....
    if y > 0 {
        for x in start..end {
            if is_special(char_map[y - 1][x]) {
                return true;
            }
        }
    }

    // ....
    // .XX.
    // CCCC
    if y + 1 < char_map.len() {
        for x in start..end {
            if is_special(char_map[y + 1][x]) {
                return true;
            }
        }
    }

    return false;
}

fn main() {
    let char_map: Vec<Vec<char>> = std::io::stdin()
        .lines()
        .map(|l| l.unwrap().chars().collect())
        .collect();

    if let Some(choice) = std::env::args().nth(1) {
        match choice.as_str() {
            "a" => solution_a(char_map),
            "b" => solution_b(char_map),
            _ => panic!("invalid arg"),
        }
    } else {
        panic!("expected arg: a|b")
    };
}

fn solution_b(char_map: Vec<Vec<char>>) {
    let width = char_map[0].len();
    let height = char_map.len();

    let mut number_map = HashMap::<(usize, usize), (usize, u64)>::new();
    let mut i = 0;
    for y in 0..height {
        let mut start: Option<usize> = None;
        for x in 0..width {
            if char_map[y][x].is_digit(10) && start.is_none() {
                start = Some(x);
            }

            if !char_map[y][x].is_digit(10) || x == width - 1 {
                if let Some(start_val) = start {
                    let span = (
                        y,
                        start_val..if x == width - 1 && char_map[y][x].is_digit(10) {
                            width
                        } else {
                            x
                        },
                    );

                    let mut string = String::with_capacity(span.1.len());
                    for x in span.1.clone() {
                        string.push(char_map[y][x]);
                    }

                    let number = string.parse().unwrap();

                    for x in span.1.clone() {
                        number_map.insert((x, y), (i, number));
                    }

                    i += 1;

                    start = None;
                }
            }
        }
    }

    let mut sum: u64 = 0;

    for y in 0..height {
        for x in 0..width {
            if char_map[y][x] == '*' {
                let mut number_set = HashSet::<(usize, u64)>::new();

                for cy in y - 1..=y + 1 {
                    for cx in x - 1..=x + 1 {
                        if let Some(v) = number_map.get(&(cx, cy)) {
                            number_set.insert(v.clone());
                        }
                    }
                }

                if number_set.len() == 2 {
                    sum += number_set.iter().map(|v| v.1).product::<u64>();
                }
            }
        }
    }

    dbg!(sum);
}

fn solution_a(char_map: Vec<Vec<char>>) {
    let width = char_map[0].len();
    let height = char_map.len();

    let mut sum: u64 = 0;

    for y in 0..height {
        let mut start: Option<usize> = None;
        for x in 0..width {
            if char_map[y][x].is_digit(10) && start.is_none() {
                start = Some(x);
            }

            if !char_map[y][x].is_digit(10) || x == width - 1 {
                if let Some(start_val) = start {
                    let span = (
                        y,
                        start_val..if x == width - 1 && char_map[y][x].is_digit(10) {
                            width
                        } else {
                            x
                        },
                    );

                    if is_surrounded_by_at_least_one_special_character(&char_map, span.clone()) {
                        let mut string = String::with_capacity(span.1.len());
                        for x in span.1.clone() {
                            string.push(char_map[y][x]);
                        }

                        sum += string.parse::<u64>().unwrap();
                    }

                    start = None;
                }
            }
        }
    }

    dbg!(sum);
}
