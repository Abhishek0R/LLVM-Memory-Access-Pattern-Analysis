        #include <stdio.h>

struct Point {
    int x;
    int y;
};

int global_var = 10;
int x =10;
double high=18;
void process_array(int *arr, int size) {
    for (int i = 0; i < size; i++) {
        arr[i] = arr[i] * 2;
    }
}

void manipulate_struct(struct Point *p) {
    p->x = p->x + 1;
    p->y = p->y + 2;
}

int main() {
    int local_var = 20;
    int array[4] = {1, 2, 3, 4};
    struct Point pt = {3, 4};
    
    global_var += 5;
    local_var *= 2;
    x +=10;
    x=10;
    process_array(array, 4);
    manipulate_struct(&pt);
    printf("Local var: %lf\n", high);
    printf("Global var: %d\n", global_var);
    printf("Local var: %d\n", local_var);
    printf("Array[2]: %d\n", array[2]);
    printf("Point: (%d, %d)\n", pt.x, pt.y);
	printf("Local var: %d\n", x);    

    return 0;
}

