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
    int isArray;   // Flag indicating if it's an array
    int arraySize; // Size of the array (if applicable)
    /* Add other relevant attributes here */
} SymbolTableEntry;

typedef struct Node {
    SymbolTableEntry data;
    struct Node* next;
} Node;

typedef struct {
    Node* front;
    Node* rear;
} Queue;

void initializeQueue(Queue* queue);
int isEmpty(Queue* queue);
void enqueue(Queue* queue, SymbolTableEntry entry);
SymbolTableEntry dequeue(Queue* queue);
void displayQueue(Queue* queue);
void destroyQueue(Queue* queue);

#endif