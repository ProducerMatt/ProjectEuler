#include <stdio.h>

double pi = 3.14159265358979323846264338327950;

double cube(double x) {
    return x * x * x;
}

double sphere_volume(double radius) {
    return (4.0 / 3.0) * pi * cube(radius);
}

int main(void) {
  double radius = 10.0;
  printf("%.1f meter sphere has a %.1f meter volume\n",
         radius, sphere_volume(radius));
  return 0;
}
