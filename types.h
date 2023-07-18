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
    struct Node* fields;
} Node;

//linked list
Node* createNode(UndefVar data);
void insertAtBeginning(Node** head, UndefVar data);
void insertAtEnd(Node** head, UndefVar data);
void displayList(Node* head);
void freeList(Node** head);
void freeFields(Node* fields);
void updateType(Node* head, DataType newType);
void concatLists(Node** list1, Node* list2);
#endif