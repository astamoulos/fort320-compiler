/* The authors of this work have released all rights to it and placed it
in the public domain under the Creative Commons CC0 1.0 waiver
(http://creativecommons.org/publicdomain/zero/1.0/).

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Retrieved from: http://en.literateprograms.org/Hash_table_(C)?oldid=19638
*/

#include"hashtbl.h"

#include<string.h>
#include<stdio.h>

static char *mystrdup(const char *s)
{
	char *b;
	if(!(b=malloc(strlen(s)+1))) return NULL;
	strcpy(b, s);
	return b;
}

static hash_size def_hashfunc(const char *key)
{
	hash_size hash=0;
	
	while(*key) hash+=(unsigned char)*key++;

	return hash;
}

HASHTBL *hashtbl_create(hash_size size, hash_size (*hashfunc)(const char *))
{
	HASHTBL *hashtbl;

	if(!(hashtbl=malloc(sizeof(HASHTBL)))) return NULL;

	if(!(hashtbl->nodes=calloc(size, sizeof(struct hashnode_s*)))) {
		free(hashtbl);
		return NULL;
	}

	hashtbl->size=size;

	if(hashfunc) hashtbl->hashfunc=hashfunc;
	else hashtbl->hashfunc=def_hashfunc;

	return hashtbl;
}

void hashtbl_destroy(HASHTBL *hashtbl)
{
	hash_size n;
	struct hashnode_s *node, *oldnode;
	
	for(n=0; n<hashtbl->size; ++n) {
		node=hashtbl->nodes[n];
		while(node) {
			if(node->fields)
				destroy_fields(node->fields);
			free(node->key);
			free(node->data);
			oldnode=node;
			node=node->next;
			free(oldnode);
		}
	}
	free(hashtbl->nodes);
	free(hashtbl);
}

void destroy_fields(struct hashnode_s* fields) {
    struct hashnode_s* temp = fields;
    while (temp) {
		
        struct hashnode_s* oldnode = temp;
        temp = temp->next;
		
        free(oldnode->key);
		
        //free(oldnode->data);
        destroy_fields(oldnode->fields); // Recursively destroy nested fields
        free(oldnode);
		
    }
}


struct hashnode_s* hashtbl_insert(HASHTBL *hashtbl, char *key, void *data ,int scope, DataType type, int isArray)
{
	struct hashnode_s *node;
	hash_size hash=hashtbl->hashfunc(key)%hashtbl->size;

	printf("\t\t\t\t\tHASHTBL_INSERT(): KEY = %s, HASH = %ld, SCOPE = %d, ", key, hash, scope);
	printf("Type = ");
	printSymbolTableEntry(type, isArray);

	node=hashtbl->nodes[hash];
	while(node) {
		if(!strcmp(node->key, key) && (node->scope == scope)) {
			node->data=data;
			printf("\t\t Symbol already exists\n");
			free(key);
			return 0;
		}
		node=node->next;
	}

	if(!(node=malloc(sizeof(struct hashnode_s)))) return NULL;
	if(!(node->key=mystrdup(key))) {
		free(node);
		return NULL;
	}
	
	node->data=data;
	node->scope = scope;
	node->isArray = isArray;
	node->type = type;
	node->next=hashtbl->nodes[hash];
	node->fields = NULL;
	hashtbl->nodes[hash]=node;

	free(key); //we need to free strdup from yylex
	return node;
}

int hashtbl_remove(HASHTBL *hashtbl, const char *key,int scope)
{
	struct hashnode_s *node, *prevnode=NULL;
	hash_size hash=hashtbl->hashfunc(key)%hashtbl->size;

	node=hashtbl->nodes[hash];
	while(node) {
		if((!strcmp(node->key, key)) && (node->scope == scope)) {
			free(node->key);
			free(node->data);
			if(prevnode) prevnode->next=node->next;
			else hashtbl->nodes[hash]=node->next;
			free(node);
			return 0;
		}
		prevnode=node;
		node=node->next;
	}

	return -1;
}

void *hashtbl_get(HASHTBL *hashtbl, int scope)
{
	int rem;
	hash_size n;
	struct hashnode_s *node, *oldnode;
		
	for(n=0; n<hashtbl->size; ++n) {
		node=hashtbl->nodes[n];
		while(node) {
			if(node->scope == scope) {
				printf("\t\t\t\t\tHASHTBL_GET():\tSCOPE = %d, KEY = %s,  \tDATA = %s\n", node->scope, node->key, (char*)node->data);
				oldnode = node;
				node=node->next;
				rem = hashtbl_remove(hashtbl, oldnode->key, scope);
			}else
				node=node->next;
		}
	}
	
	if (rem == -1)
		printf("\t\t\t\t\tHASHTBL_GET():\tThere are no elements in the hash table with this scope!\n\t\tSCOPE = %d\n", scope);
	
	return NULL;
}

void printSymbolTableEntry(DataType type, int isArray) {
	char dataType[17];
	switch (type) {
        case INT_TYPE:
            strcpy(dataType,"INTEGER");
            break;
        case REAL_TYPE:
            strcpy(dataType,"REAL");
            break;
        case LOGICAL_TYPE:
            strcpy(dataType,"LOGICAL");
            break;
        case CHARACTER_TYPE:
            strcpy(dataType,"CHARACTER");
            break;
		case RECORD_TYPE:
            strcpy(dataType,"RECORD");
            break;
    }

	if (isArray) {
        printf("%s ARRAY\n", dataType);
    } else {
        printf("%s\n", dataType);
    }
}
/*
void hashtbl_print(HASHTBL *hashtbl)
{
	hash_size n;
	struct hashnode_s *node;
	struct hashnode_s *temp;
	printf("------------  ------------------ \n");
	printf("Name          Type   			 \n");
	printf("------------  ------------------ \n");
	for(n=0; n<hashtbl->size; ++n) {
		node=hashtbl->nodes[n];
		while(node) {
			printf("%-12s  ", node->key);
			printSymbolTableEntry(node->type, node->isArray);
			if(node->fields){
				temp = node->fields;
				while(temp){
					printf("    %-12s  ", temp->key);
					printSymbolTableEntry(temp->type, temp->isArray);
					temp = temp->next;
				}
			}
			node=node->next;
		}
	}
}
*/
void printFields(struct hashnode_s* fields, int indentation) {
    struct hashnode_s* temp = fields;

    while (temp) {
        for (int i = 0; i < indentation; ++i) {
            printf("    "); // Print tabs for indentation
        }
		
		printf("╰┈➤");
        printf(" %s: ", temp->key);
        printSymbolTableEntry(temp->type, temp->isArray);
		
        if (temp->fields) {
            printFields(temp->fields, indentation + 1); // Recursive call with increased indentation
        } else {
			if(temp->next){
				for (int i = 0; i < indentation; ++i)
					printf("    "); // Print tabs for indentation
				printf("|");
			}
            printf("\n");
        }
		
        temp = temp->next;
    }
}

void hashtbl_print(HASHTBL *hashtbl) {
    hash_size n;
    struct hashnode_s *node;
    struct hashnode_s *temp;
	printf("\n------ -----\n");
    printf("Symbol Table\n");
    printf("------ -----\n");
    printf("Name   Type\n");
    printf("------ -----\n");
    for (n = 0; n < hashtbl->size; ++n) {
        node = hashtbl->nodes[n];
        while (node) {
            printf("%s: ", node->key);
            printSymbolTableEntry(node->type, node->isArray);
            if (node->fields) {
                printFields(node->fields, 1); // Call to print nested fields with initial indentation of 1
            }
            node = node->next;
        }
    }
}
