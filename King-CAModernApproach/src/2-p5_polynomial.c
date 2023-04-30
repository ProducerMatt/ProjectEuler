#include <stdio.h>
double exp_d(double x, int e) {
  double result = 1;
  for (int i = 0; i < e; i++) {
    result *= x;
  }
  return result;
}

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
         3 * exp_d(x, 5) + 2 * exp_d(x, 4) - 5 * exp_d(x, 3)
           - exp_d(x, 2) + 7 * x - 6);
  return 0;
}
