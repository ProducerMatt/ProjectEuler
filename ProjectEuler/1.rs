fn div_3_or_5(n: u64) -> bool {
    debug_assert!(n >= 3);
    n % 3 == 0 || n % 5 == 0
}

fn main() {
    let mut total: u64 = 0;

    for n in 3..1000 {
        if div_3_or_5(n) {
            total += n
        }
    }

    println!("{total}");
}
