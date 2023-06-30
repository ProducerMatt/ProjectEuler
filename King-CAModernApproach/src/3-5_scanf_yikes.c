#include <stdio.h>
#include <stdlib.h>

int main(void) {
  float x, y = 0.0f; int i, status = 0;
  char* s = "12.3 45.6 789";

  printf("input string of 3 numbers: %s\n\n", s);

  status = sscanf(s, "%f%d%f", &x, &i, &y);

  printf("results:\nx = %f\ni = %d\ny = %f\nTotal scanned: %d\n", x, i, y, status);

  return 0;
}
