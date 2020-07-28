#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <cuda.h>
//1073741824
#define size 16384
#define threadsize 1024

__global__
void MatrixAddition(int *a, int *b, int *c){
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
       matC[i] = 0;
    }

    
    
    
    dim3 dimGrid(size/threadsize/2,1);
    dim3 dimBlock(32,32);

    cudaStream_t stream[2];
    
    int *matAD[2]; int *matBD[2]; int *matCD[2];
    int *matAP;int *matBP; int *matCP;
    cudaMallocHost((void**)&matAP,totalsize);
    cudaMallocHost((void**)&matBP,totalsize);
    cudaMallocHost((void**)&matCP,totalsize);
    memcpy(matAP,matA, totalsize);
    memcpy(matBP,matB, totalsize);
   memcpy(matCP,matC, totalsize);

    
    cudaSetDevice(0);
    
    cudaMalloc((void**)&matAD[0],totalsize/2);
    cudaMalloc((void**)&matBD[0], totalsize/2);
    cudaMalloc((void**)&matCD[0], totalsize/2);
    cudaStreamCreateWithFlags(&stream[0],cudaStreamNonBlocking);
   

    cudaSetDevice(1);
  
    cudaMalloc((void**)&matAD[1],totalsize/2);
    cudaMalloc((void**)&matBD[1], totalsize/2);
    cudaMalloc((void**)&matCD[1], totalsize/2);
  
    
    cudaStreamCreateWithFlags(&stream[1],cudaStreamNonBlocking);
   
    
   
   
    cudaSetDevice(0);
    cudaMemcpyAsync(matAD[0], &matAP[0*size/2], totalsize/2, cudaMemcpyHostToDevice,stream[0]);
    cudaMemcpyAsync(matBD[0], &matBP[0*size/2], totalsize/2, cudaMemcpyHostToDevice,stream[0]); 
    cudaSetDevice(1);
    cudaMemcpyAsync(matAD[1], &matAP[1*size/2], totalsize/2, cudaMemcpyHostToDevice,stream[1]);
    cudaMemcpyAsync(matBD[1], &matBP[1*size/2], totalsize/2, cudaMemcpyHostToDevice,stream[1]);

  
    cudaSetDevice(0);
    MatrixAddition<<<dimGrid, dimBlock,0,stream[0]>>>(matAD[0],matBD[0], matCD[0]);
   cudaSetDevice(1);
    MatrixAddition<<<dimGrid, dimBlock,0,stream[1]>>>(matAD[1],matBD[1], matCD[1]);
   

    cudaSetDevice(0);
    cudaMemcpyAsync(&matCP[0*size/2], matCD[0], totalsize/2, cudaMemcpyDeviceToHost,stream[0]);
    cudaSetDevice(1);
    cudaMemcpyAsync(&matCP[1*size/2], matCD[1], totalsize/2, cudaMemcpyDeviceToHost,stream[1]);
   
    memcpy(matC, matCP, totalsize);
   

   

for(int i = 0; i < size; i++){
    summation += matCP[i];
}
    printf("Sum is %lld ", summation);
    cudaFree(matAD);
    cudaFree(matBD);
    cudaFree(matCD);
    cudaFreeHost(matAP);
    cudaFreeHost(matBP);
    cudaFreeHost(matCP);
}