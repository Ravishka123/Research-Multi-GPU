#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <cuda.h>

#define size 1073741824
#define threadsize 1024
#define partitions 2

__global__
void MatrixAddition(int *a, int *b, int *c){
    //1d grid with 2d blocks
    int id = blockIdx.x *blockDim.x * blockDim.y + threadIdx.y * blockDim.x+ threadIdx.x;

    c[id] = a[id] + b[id];
}

int main(){

    const long long int totalsize = size*sizeof(int);
    
    long long int summation = 0;

    float time1, time2 = 0.0;

    int *matA = (int*)malloc(totalsize);
    int *matB = (int*)malloc(totalsize);
    int *matC = (int*)malloc (totalsize);

    for(int i = 0; i < size;i++){
        matA[i] = 1;
        matB[i] = 2;
       // matC[i] = 0;
    }


    int *matAD; int *matBD; int *matCD;
    cudaMalloc((void**)&matAD,totalsize/partitions);
    cudaMalloc((void**)&matBD, totalsize/partitions);
    cudaMalloc((void**)&matCD, totalsize/partitions);

    cudaEvent_t start1,end1;
    cudaEventCreate(&start1);
    cudaEventCreate(&end1);

    //computing by partitions
   for(int k= 0; k<partitions; k++){

    cudaMemcpy(matAD, &matA[k*size/partitions], totalsize/partitions, cudaMemcpyHostToDevice);
    cudaMemcpy(matBD, &matB[k*size/partitions], totalsize/partitions, cudaMemcpyHostToDevice);

    dim3 dimGrid(size/threadsize/partitions,1);
    dim3 dimBlock(32,32);
    cudaEventRecord(start1);
    MatrixAddition<<<dimGrid, dimBlock>>>(matAD,matBD, matCD);
    cudaEventRecord(end1);
    cudaMemcpy(&matC[k*size/partitions], matCD, totalsize/partitions, cudaMemcpyDeviceToHost);
    cudaEventSynchronize(end1);
    cudaEventElapsedTime(&time1,start1,end1);

    time2+= time1;

}

printf("elapsed time is %lf milli secs \n",time2);
for(int i = 0; i < size; i++){
    summation += matC[i];
}
    printf("Sum is %lld ", summation);
    cudaFree(matAD);
    cudaFree(matBD);
    cudaFree(matCD);
}