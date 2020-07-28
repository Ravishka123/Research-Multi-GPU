#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include <stdint.h>

#define size 16384
#define billion 1000000000L
#define width 128

void MatrixAddition(int *a,int*b, int *c);

int main(){
    const long long int totalsize = size*sizeof(int);
    long long int summation = 0;
    uint64_t diff;
    struct timespec start, end;

    int *matA = (int *)malloc(totalsize);
    int *matB = (int*)malloc(totalsize);
    int *matC = (int *)malloc(totalsize);

    for(int i = 0; i<size;i++){
        matA[i] = 1;
        matB[i]= 2;
        matC[i]=0;
    }

    clock_gettime(CLOCK_MONOTONIC, &start);
    MatrixAddition(matA,matB,matC);
    clock_gettime(CLOCK_MONOTONIC, &end);
    //compute time in milli seconds, nano seconds / 1000000
    diff = billion *(end.tv_sec - start.tv_sec) + end.tv_nsec - start.tv_nsec;
    printf(" elapsed time = %lf milli seconds\n", diff/1000000.0);

    for(int i = 0; i< size;i++){
        summation += matC[i];
    }
    printf("Sum is %lld ", summation);

}

void MatrixAddition(int *a,int*b, int *c){
    for(int k=0; k<width;k++){
        for(int j = 0; j < width; j++){
        c[k*width + j]= a[k*width +j]+b[k*width +j];
        }
    }
}

