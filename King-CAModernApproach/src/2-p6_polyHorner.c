#include <stdio.h>

int main(void) {
  double x = 0;
  int result = 0;

  printf("Solving 3x^5 + 2x^4 - 5x^3 - x^2 + 7x - 6\n\n");
  printf("Enter 'x' as a decimal number: ");
  result = scanf("%lf", &x);
  if (result != 1) {
    printf("something went wrong");
    return 1;
  }
  printf("Answer: %lf",
         (((((((((3 * x) + 2) * x) - 5) * x) - 1) * x) + 7) * x) - 6);
  return 0;
}
