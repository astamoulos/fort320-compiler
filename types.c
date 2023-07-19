#include <stdio.h>
#include "types.h"
#include <stdlib.h>
#include <string.h>

Node* createNode(UndefVar data) {
    Node* newNode = (Node*)malloc(sizeof(Node));
    newNode->data = data;
    newNode->next = NULL;
    newNode->fields= NULL;
    return newNode;
}

// Function to insert a Node at the beginning of the linked list
void insertAtBeginning(Node** head, UndefVar data) {
    Node* newNode = createNode(data);
    newNode->next = *head;
    *head = newNode;
}

// Function to insert a Node at the end of the linked list
void insertAtEnd(Node** head, UndefVar data) {
    Node* newNode = createNode(data);
    if (*head == NULL) {
        *head = newNode;
        return;
    }
    Node* temp = *head;
    while (temp->next != NULL) {
        temp = temp->next;
    }
    temp->next = newNode;
}

// Function to display the linked list
void displayList(Node* list) {
    printf("Display list!\n");
    Node* curr = list;

    while (curr != NULL) {
        printf("Name: %s\n", curr->data.name);

        Node* field = curr->fields;
        while (field != NULL) {
            printf("\tField Name: %s\n", field->data.name);

            // Check if the field has its own fields
            if (field->fields != NULL) {
                Node* nestedField = field->fields;
                while (nestedField != NULL) {
                    printf("\t\tNested Field Name: %s\n", nestedField->data.name);
                    nestedField = nestedField->next;
                }
            }

            field = field->next;
        }

        printf("\n");
        curr = curr->next;
    }
}


// Function to free the memory allocated for the linked list
void freeList(Node** head) {
    Node* current = *head;
    Node* next;
    while (current != NULL) {
        next = current->next;
        freeFields(current->fields);
        free(current);
        current = next;
    }
    *head = NULL;
}

void freeFields(Node* fields) {
    Node* current = fields;
    Node* next;
    
    while (current != NULL) {
        next = current->next;
        free(current);
        current = next;
    }
}

void updateType(Node* head, DataType newType) {
    Node* temp = head;
    while (temp != NULL) {
        temp->data.type = newType;
        temp = temp->next;
    }
}

void concatLists(Node** list1, Node* list2) {
    if (*list1 == NULL) {
        *list1 = list2;
    } else {
        Node* temp = *list1;
        while (temp->next != NULL) {
            temp = temp->next;
        }
        temp->next = list2;
    }
}