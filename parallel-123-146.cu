/*
	* Team - Suraj Singh and Mahir Jain 
	* Roll Numbers - 16CO146 and 16CO123 respectively.
*/
#include <stdio.h>
#include <cuda.h>
#include <time.h>

#define r_size 10
#define c_size 28
// Only one black is used.
#define BLOCKS 1
// Depends on the GPU used.
#define THREADS 1024


// Function for calculating execution time
void print_elapsed(clock_t start, clock_t stop)
{
  double elapsed = ((double) (stop - start)) / CLOCKS_PER_SEC;
  printf("Elapsed time: %fs\n", elapsed);
}


// Main CUDA kernel
// most of the parameters here are too big to be stored in shared memory
// and hence we have used global memory instead
__global__ void brandes(int s, int *R, int *C, int  *S, int *d, float *sigma, float *delta, int *Q, int *Q2, int * ends, float *bc) {
    
    int idx = threadIdx.x;
    // Initialise values for BFS
    for(int k=idx; k < r_size; k+= blockDim.x) {
        //printf("hi");
        if( k == s ) {
            d[k] = 0;
            sigma[k] =1;
        } else {
            d[k] = -1;
            sigma[k] = 0;
        }
    }
	// initialize variables common to all threads in the block that fit in shared memory
    __shared__ int Q_len;
    __shared__ int Q2_len;
    __shared__ int ends_len;
    __shared__ int depth;
    __shared__ int S_len;
    int count;
 
    if( idx == 0 ) {
        Q[0] = s;
        Q_len = 1;
        S[0] = s;
        S_len=1;
        Q2_len = 0;
        ends[0] =0;
        ends[1] = 1;
        ends_len = 2;
    }

    __syncthreads();

    count =0;
    while(1) {
        for(int k=idx; k < ends[count+1] - ends[count]; k+=blockDim.x) {
            int v = Q[k];            
            // Same logic as ocean kernel! 
            __syncthreads();
            for(int r = R[v]; r< R[v+1]; r++) {
                int w = C[r];
            
                int t;
                // Adding neighbours to our 'stack' implemented as a queue
                if (atomicCAS(&d[w], -1, d[v]+1) == -1) {
                    //printf("%d\n", w);
                    t = atomicAdd(&Q2_len,1);
                        //f =1;
                    Q2[t] = w;
                }
				// if v was the shortest path to w, update sigma
                
                if(d[w] == (d[v]+1)) {
                    atomicAdd(&sigma[w],sigma[v]);
                }
            }
        }
        __syncthreads();

        if(Q2_len==0) {
            if(idx==0) {
            // calculate depth for next section of code
                depth = d[S[S_len-1]];
            }
            break;
        } else {
        // swap Q with Q2
            for(int k =idx; k < Q2_len; k+=blockDim.x) {
                Q[k] = Q2[k];
                S[k+S_len]  = Q2[k];
            }
            __syncthreads();
            if(idx==0) {
                ends[ends_len] = ends[ends_len-1] + Q2_len;
                ends_len = ends_len +1;
                Q_len = Q2_len;
                S_len = S_len + Q2_len;
                Q2_len = 0;
            }
            __syncthreads();
            

        }

        count++;
        __syncthreads();

    }
    // everyone needs to stop after breaking out of while loop
    __syncthreads();
    while(depth > 0) {
    // all threads execute in parallel
        if(idx >= ends[depth] && idx <= ends[depth+1] -1)
        {
            int w = S[idx];
            float dsw = 0;
            float sw = sigma[w];
            // update delta for a vertex by traversing its neighbours 
            for(int r = R[w]; r< R[w+1]; r++) {
                int v = C[r];
                if(d[v] == d[w] + 1) {
                    dsw += (sw/sigma[v])*(1 + delta[v]);
                }
            }
            delta[w] = dsw;
            __syncthreads();
            // add to BC value of the vertex!
            if(w!=s) {
                atomicAdd(&bc[w],delta[w]/2);
                //bc[w] += delta[w]/2;
            }
        }
        depth--;
    }


}


int main(int argc, char const *argv[])
{
    FILE *R = fopen("R.txt", "r");
    FILE *C = fopen("C.txt", "r");
    clock_t start, stop;
    int r[r_size];
    int c[c_size];
    for(int i=0;i< r_size; i++) {
        fscanf(R, "%d\n", &r[i]);
    }
    for(int i=0;i< c_size; i++) {
        fscanf(C, "%d\n", &c[i]);
    }

    int *dev_r, *dev_c, *dev_d, *dev_Q, *dev_Q2,*ends, *dev_S;

    float *dev_sigma, *dev_delta, *dev_bc;
    float *bc_val = (float*)malloc(r_size*sizeof(float));


    cudaMalloc((void**) &dev_r, r_size*sizeof(int));
    cudaMalloc((void**) &dev_c, c_size*sizeof(int));
    cudaMalloc((void**) &dev_bc, r_size*sizeof(float));
    cudaMalloc((void**) &dev_d, r_size*sizeof(int));
    cudaMalloc((void**) &dev_sigma, r_size*sizeof(float));
    cudaMalloc((void**) &dev_delta, r_size*sizeof(float));
    cudaMalloc((void**) &dev_Q, r_size*sizeof(int));
    cudaMalloc((void**) &dev_Q2, r_size*sizeof(int));
    cudaMalloc((void**) &dev_S, r_size*sizeof(int));
    cudaMalloc((void**) &ends, (r_size+1)*sizeof(int));


    cudaMemcpy(dev_r, r, r_size*sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(dev_c, c, c_size*sizeof(int), cudaMemcpyHostToDevice);


    dim3 blocks(BLOCKS,1);
    dim3 threads(THREADS,1);

    start = clock();
    for(int s=0; s < r_size; s++) {
        brandes<<<blocks, threads>>>(s, dev_r, dev_c, dev_S, dev_d , dev_sigma, dev_delta,dev_Q,dev_Q2, ends, dev_bc);
     }
    stop=clock();
    
    print_elapsed(start,stop);
    cudaMemcpy(bc_val, dev_bc, r_size*(sizeof(float)), cudaMemcpyDeviceToHost);

   


    return 0;
}
