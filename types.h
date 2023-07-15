#ifndef TYPES_H
#define TYPES_H
#include <stdio.h>
#include <stdlib.h>

typedef enum {
    INT_TYPE,
    REAL_TYPE,
    LOGICAL_TYPE,
    CHARACTER_TYPE,
    RECORD_TYPE
} DataType;

typedef struct {
    char* name;
    DataType type;
    int isArray;
    int arraySize;
} UndefVar;

typedef struct Node {
    UndefVar data;
    struct Node* next;
} Node;

typedef struct {
    Node* front;
    Node* rear;
} Queue;

typedef struct Field{
	char *name;
	DataType type;
    struct Field *next;
}Field;

void initializeQueue(Queue* queue);
int isEmpty(Queue* queue);
void enqueue(Queue* queue, UndefVar entry);
UndefVar dequeue(Queue* queue);
void displayQueue(Queue* queue);
void destroyQueue(Queue* queue);
void addQueues(Queue* queue1, Queue* queue2);
void assignTypeToQueue(Queue* queue, DataType newType);

#endif