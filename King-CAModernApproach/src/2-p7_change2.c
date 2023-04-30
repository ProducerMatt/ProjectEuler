#include <stdio.h>

void spend_denom(int *dollars, int *denom) {
  // denom uses initial value as denomination value,
  // then is replaced with quantity of denom used.
  int quotient = *dollars / *denom;
  *dollars -= quotient * *denom;
  *denom = quotient;
}
int main(void) {
  int dollars, result = 0;
  int twenties = 20;
  int tens = 10;
  int fives = 5;
  int ones = 1;
  printf("Enter a dollar value (int): ");
  result = scanf("%d", &dollars);
  if (result != 1) {
    printf("something went wrong");
    return 1;
  }
  spend_denom(&dollars, &twenties);
  spend_denom(&dollars, &tens);
  spend_denom(&dollars, &fives);
  spend_denom(&dollars, &ones);

  printf("Twenties: %d\nTens: %d\n", twenties, tens);
  printf("Fives: %d\nOnes: %d\n", fives, ones);
  return 0;
}
