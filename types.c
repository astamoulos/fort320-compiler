#include <stdio.h>
#include "types.h"
#include <stdlib.h>

// Function to initialize an empty queue
void initializeQueue(Queue* queue) {
    queue->front = queue->rear = NULL;
}

// Function to check if the queue is empty
int isEmpty(Queue* queue) {
    return (queue->front == NULL);
}

// Function to enqueue a new element
void enqueue(Queue* queue, SymbolTableEntry entry) {
    Node* newNode = (Node*)malloc(sizeof(Node));
    newNode->data = entry;
    newNode->next = NULL;

    if (isEmpty(queue)) {
        queue->front = queue->rear = newNode;
    } else {
        queue->rear->next = newNode;
        queue->rear = newNode;
    }
}

// Function to dequeue an element
SymbolTableEntry dequeue(Queue* queue) {
    if (isEmpty(queue)) {
        printf("Queue is empty.\n");
        exit(1);
    }

    Node* temp = queue->front;
    SymbolTableEntry entry = temp->data;
    queue->front = queue->front->next;

    if (queue->front == NULL) {
        queue->rear = NULL;
    }

    free(temp);
    return entry;
}

// Function to display the queue elements
void displayQueue(Queue* queue) {
    if (isEmpty(queue)) {
        printf("Queue is empty.\n");
        return;
    }

    Node* temp = queue->front;
    printf("Queue elements:\n");

    while (temp != NULL) {
        printf("Name: %s, Type: %d, isArray: %d, arraySize: %d\n",
               temp->data.name, temp->data.type, temp->data.isArray, temp->data.arraySize);
        temp = temp->next;
    }
}

// Function to free the memory allocated for the queue
void destroyQueue(Queue* queue) {
    while (!isEmpty(queue)) {
        dequeue(queue);
    }
}