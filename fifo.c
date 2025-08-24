
//#include<queue>
#include<stdio.h>
#include<stdbool.h>
#include<svdpi.h>

#define FIFO_SIZE 16

typedef struct{
  int q[FIFO_SIZE];
  int read;
  int write;
  int size;
} Queue;

Queue queue;

int pop(){
    if(queue.size==0){
	return queue.q[queue.read];
    }else{
	queue.size=queue.size-1;
 	int val = queue.q[queue.read];
        queue.read=(queue.read+1)%FIFO_SIZE;
	return val;	
    }
}

int front(){
    return queue.q[queue.read];
}

void push(int val){
    if(queue.size==FIFO_SIZE){
	return;
    }else{
	queue.size=queue.size+1;
	queue.q[queue.write]=val;
        queue.write=(queue.write+1)%FIFO_SIZE;
    }
}
svLogic is_empty(){   
   return queue.size==0;
}
svLogic is_full(){
    return queue.size==FIFO_SIZE;
}
svLogic near_empty(){
  return queue.size<=FIFO_SIZE/4;
}
svLogic near_full(){
  return queue.size>=FIFO_SIZE*3/4;
}
void rreset(){
  queue.size=0;
  queue.read=0;
}
void wreset(){
  queue.size=0;
  queue.write=0;
}

