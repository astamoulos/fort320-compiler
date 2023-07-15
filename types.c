#include <stdio.h>
#include "types.h"
#include <stdlib.h>

void initializeQueue(Queue* queue) {
    queue->front = queue->rear = NULL;
}

int isEmpty(Queue* queue) {
    return (queue->front == NULL);
}

void enqueue(Queue* queue, UndefVar entry) {
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

UndefVar dequeue(Queue* queue) {
    if (isEmpty(queue)) {
        printf("Queue is empty.\n");
        exit(1);
    }

    Node* temp = queue->front;
    UndefVar entry = temp->data;
    queue->front = queue->front->next;

    if (queue->front == NULL) {
        queue->rear = NULL;
    }
    
    free(temp);
    return entry;
}

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

void destroyQueue(Queue* queue) {
    while (!isEmpty(queue)) {
        dequeue(queue);
    }
}

void addQueues(Queue* queue1, Queue* queue2) {
    if (isEmpty(queue2)) {
        // Nothing to add if the second queue is empty
        return;
    }

    if (isEmpty(queue1)) {
        // If the first queue is empty, set the front and rear of the first queue to the second queue
        queue1->front = queue2->front;
        queue1->rear = queue2->rear;
    } else {
        // If the first queue is not empty, link the rear of the first queue to the front of the second queue
        queue1->rear->next = queue2->front;
        queue1->rear = queue2->rear;
    }

    // Reset the second queue
    initializeQueue(queue2);
}

void assignTypeToQueue(Queue* queue, DataType newType) {
    Node* current = queue->front;
    while (current != NULL) {
        current->data.type = newType;
        current = current->next;
    }
}