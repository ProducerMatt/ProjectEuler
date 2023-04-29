#include <stdio.h>

double pi = 3.14159265358979323846264338327950;

double cube(double x) {
    return x * x * x;
}

double sphere_volume(double radius) {
    return (4.0 / 3.0) * pi * cube(radius);
}

int main(void) {
  double radius;
  int result = 0;
  printf("Please enter sphere radius in meters: ");
  result = scanf("%lf", &radius);
  if (result != 1) {
    printf("something went wrong\n");
    return 1;
  }
  printf("%.1f meter sphere has a %.1f meter volume\n",
         radius, sphere_volume(radius));
  return 0;
}
