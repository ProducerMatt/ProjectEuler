fn main() {
    let mut a = 1;
    let mut b = 2;
    let mut sum = 2;

    loop {
        if sum > 4_000_000 {
            break;
        }
        let next = a + b;
        if next % 2 == 0 {
            sum += next;
        }
        a = b;
        b = next;
    }
    println!("{sum}");
}
