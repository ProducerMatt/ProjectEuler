#include <stdio.h>

static double loan_update(double loan, double pct, double monthly, int monthnum){
  double newloan = (loan + (loan * pct)) - monthly;
  printf("Balance after month %d: %0.2f\n", monthnum, newloan);
  return newloan;
}

int main(void) {
  int result;
  double loan, pct, monthly;

  printf("Enter a loan amount: ");
  result = scanf("%lf", &loan);
  if (result != 1) {
    printf("something went wrong");
    return 1;
  }

  printf("Enter a yearly percent: ");
  result = scanf("%lf", &pct);
  if (result != 1) {
    printf("something went wrong");
    return 1;
  }

  // convert to monthly percentage
  pct = (pct * 0.01) / 12;

  printf("Enter a monthly payment: ");
  result = scanf("%lf", &monthly);
  if (result != 1) {
    printf("something went wrong");
    return 1;
  }

  printf("\n");

  loan = loan_update(loan, pct, monthly, 1);
  loan = loan_update(loan, pct, monthly, 2);
  loan = loan_update(loan, pct, monthly, 3);

  return 0;
}
