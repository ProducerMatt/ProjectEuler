#include <stdio.h>

int main(void) {
  int dollars, result, twenties,
      tens, fives, ones = 0;
  printf("Enter a dollar value (int): ");
  result = scanf("%d", &dollars);
  if (result != 1) {
    printf("something went wrong");
    return 1;
  }
  twenties = dollars / 20;
  dollars -= twenties * 20;
  tens = dollars / 10;
  dollars -= tens * 10;
  fives = dollars / 5;
  dollars -= fives * 5;
  ones = dollars / 1;
  dollars -= ones * 1;

  printf("Twenties: %d\nTens: %d\n", twenties, tens);
  printf("Fives: %d\nOnes: %d\n", fives, ones);
  return 0;
}
