#include <stdio.h>
#include <math.h>
#include "kappalib.h"

int factorial(int n) {
if (n <= 0) {
return 1;
} else {
return n * factorial(n - 1);
}
}

int main(){
num = readInteger();

result = factorial(num);

writeStr("Factorial of ");
writeInteger(num);
writeStr(" is ");
writeInteger(result);
writeStr("\n");
}

