#ifndef TYPES_H
#define TYPES_H
#include <stdio.h>
#include <stdlib.h>

typedef enum {
    INT_TYPE,
    REAL_TYPE,
    LOGICAL_TYPE,
    CHARACTER_TYPE,
} DataType;

typedef struct {
    char* name;
    DataType type;
    int isArray;   // Flag indicating if it's an array
    int arraySize; // Size of the array (if applicable)
    /* Add other relevant attributes here */
} SymbolTableEntry;

#endif
