#include <stdio.h>
double five_pct(double cash){
  return cash + (cash * 0.05);
}
int main(void) {
  double cash = 0.0;
  int result = 0;
  printf("Enter a value in dollars and cents: ");
  result = scanf("%lf", &cash);
  if (result != 1) {
    printf("something went wrong");
    return 1;
  }
  printf("$%.2lf with 5%% tax = $%.2lf\n", cash, five_pct(cash));
  return 0;
}
