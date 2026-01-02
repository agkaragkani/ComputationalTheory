#include <stdio.h>
#include <math.h>
#include "kappalib.h"

const int N = 10;


int fibonacci(int n) {
if (n <= 1) {
return n;
} else {
return fibonacci(n - 1) + fibonacci(n - 2);
}
}

int main(){
int result;

result = fibonacci(N);

writeInteger(result);
}
