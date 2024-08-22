#include <stdio.h>

struct Mystruct {
    int field0;
    int field1;
};

int a;
int MyArray[3];

void function1() {
    struct Mystruct myStruct; 

    a = 10;

    MyArray[0] = 5;  
    MyArray[0] = myStruct.field0;
    myStruct.field1 = a;
}

void function2() {
    int b;
    b = 20;

    MyArray[0] = b;  
    MyArray[0] = a;  
}

int main() {
    function1();
    function2();
    return 0;
}

