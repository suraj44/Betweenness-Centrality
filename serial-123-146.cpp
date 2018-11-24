/*
  * Names - Suraj Singh and Mahir Jain
  * Roll Numbers - 16CO146 and 16CO123 
*/

#include <iostream>
#include <bits/stdc++.h>
#include <stdio.h>
#include <time.h>

#define r_size 10001
#define c_size 30100
#define BLOCKS 1
#define THREADS 1<<4

using namespace std;

void print_elapsed(clock_t start, clock_t stop)
{
  double elapsed = ((double) (stop - start)) / CLOCKS_PER_SEC;
  printf("Elapsed time: %fs\n", elapsed);
}

int main(int argc, char const *argv[])
{
    FILE *R = fopen("0_r", "r");
    FILE *C = fopen("0_c", "r");
    clock_t start, end;

    int r[r_size];
    int c[c_size];
    for(int i=0;i< r_size; i++) {
        fscanf(R, "%d\n", &r[i]);
    }
    for(int i=0;i< c_size; i++) {
        fscanf(C, "%d\n", &c[i]);
    }

    printf("\n");

    vector<float> cb;
    

    start = clock();
    
    // Initialize initial CB values
    
    for(int i=0;i < r_size-1;i++) {
        cb.push_back(0);
    }
    

    // For every node in the graph as starting, perform BFS
    for(int s =0; s < r_size-1; s++) {
        stack<int> S;
        vector<int> d;
        vector<int> prev;
        queue<int> Q;
        vector<float> sigma;
        map< int, vector<int> > P; // map for mapping neighbours of a vertex to itself

        // Initialize various BFS variables
        for(int i=0;i < r_size;i++) {
            d.push_back(-1);
            sigma.push_back(0);
            prev.push_back(0);
        }
        sigma[s] = 1;
        d[s] = 0;
        Q.push(s);
        // Perform the BFS
        while(!Q.empty()) {
            // Remove v from the Queue
            int v = Q.front();
            Q.pop();
            S.push(v);

            int m;
            if(v+1 >= r_size) {
                m = c_size;
            } else {
                m = r[v+1];
            }
            // Traverse the neighbours of v
            for(int j =r[v]; j< r[v+1]; j++) {
                int w = c[j];
                if(d[w] < 0) {
                    Q.push(w);
                    d[w] = d[v] +1;
                }
                
                // Update sigma value of w if path through v was shortest
                if(d[w] == d[v] +1) {
                    sigma[w] = sigma[w] + sigma[v];
                    P[w].push_back(v);
                }
            }
        }
        vector<float> delta;
        for(int i=0;i < r_size;i++) {
            delta.push_back(0);
        }
        // Pop elements out of the stack, starting from terminal node 
        // work backward frontier b frontier, computing delta values
        while(!S.empty()) {
            int w = S.top();
            S.pop();
            vector<int>::iterator it; // we needed an iterator as we used an STL vector
            for(it = P[w].begin(); it != P[w].end(); it++)    {
                int v = *it;
                delta[v] += ((sigma[v]/sigma[w])*(1+ delta[w]));
                
            } 
            if(w!= s) {
                    cb[w] += delta[w]/2;
                }   
        }
        // for(int i=0; i < r_size; i++) {
        //     printf("%f ", cb[i]);
        // }
    }
    end = clock();
    print_elapsed(start, end);

    printf("\n");

    print_elapsed(start, end);

    float maxi = -1;
    for(int i=0; i < r_size-1; i++) {
        if(cb[i]>maxi) {
            maxi = cb[i];
        }
    }
    printf("BC of graph: %f\n", maxi);

    return 0;

}

