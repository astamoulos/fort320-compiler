%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "hashtbl.h"
    
    #define YYDEBUG 1

    extern FILE * yyin;
    extern int yylex();
    extern void yyerror(const char *err);
    SymbolTableEntry* make_entry(DataType type, int isArray);
    void initializeQueue(Queue* queue);
    int isEmpty(Queue* queue);
    void enqueue(Queue* queue, SymbolTableEntry entry);
    SymbolTableEntry dequeue(Queue* queue);
    void displayQueue(Queue* queue);
    void destroyQueue(Queue* queue);
    void addToSymbolTable(Queue* queue, DataType type);

    HASHTBL *hashtbl;
    int scope = 0;
    DataType current_type;
%}

%define parse.error verbose

%union{
    int intval;
    float floatval;
    char charval;
    char* strval;
    
    DataType basictype;
    SymbolTableEntry undef_var;
    Queue queue;
}

// KEYWORDS
%start program
%token FUNCTION "FUNCTION"
%token SUBROUTINE "SUBROUTINE"
%token END "END"
%token INTEGER "INTEGER"
%token REAL "REAL"
%token LOGICAL "LOGICAL"
%token CHARACTER "CHARACTER"
%token RECORD "RECORD"
%token ENDREC "ENDREC"
%token DATA "DATA"
%token CONTINUE "CONTINUE"
%token GOTO "GOTO"
%token CALL "CALL"
%token READ "READ"
%token WRITE "WRITE"
%token IF "IF"
%token THEN "THEN"
%token ELSE "ELSE"
%token ENDIF "ENDIF"
%token DO "DO"
%token ENDDO "ENDDO"
%token STOP "STOP"
%token RETURN "RETURN"

//IDENTIFIER
%token <strval> ID "Identifier"

//Constants
%token <intval> ICONST "ICONST"
%token <floatval> RCONST "RCONST"
%token LCONST "LCONST"
%token <charval> CCONST "CCONST"

//Operators
%token OROP ".OR."
%token ANDOP ".AND."
%token NOTOP ".NOT."
%token RELOP
%token ADDOP "+ or -" 
%token MULOP "*"
%token DIVOP "/"
%token POWEROP "**"

//Strings
%token STRING "String"

//Other
%token LPAREN "("
%token RPAREN ")"
%token COMMA ","
%token ASSIGN "="
%token COLON ":"

%token T_EOF 0 "end of file"

%left OROP
%left ANDOP
%precedence NOTOP
%nonassoc RELOP
%left ADDOP
%left MULOP DIVOP
%right POWEROP
%left COLON LPAREN RPAREN

%type <basictype> type
%type <undef_var> undef_variable
%type <queue> vars

%%
program :                   body END subprograms
                            ;
body :                      declarations statements
                            ;
declarations :              declarations type vars {displayQueue(&$3); addToSymbolTable(&$3, $2); destroyQueue(&$3); printf("queue destroyed\n");}
                            | declarations RECORD fields ENDREC vars {addToSymbolTable(&$5, RECORD_TYPE); destroyQueue(&$5); printf("queue destroyed\n");}
                            | declarations DATA vals
                            | %empty
                            ;
type :                      INTEGER             {$$ = INT_TYPE; current_type = INT_TYPE;} 
                            | REAL              {$$ = REAL_TYPE; current_type = REAL_TYPE;} 
                            | LOGICAL           {$$ = LOGICAL_TYPE; current_type = LOGICAL_TYPE;} 
                            | CHARACTER         {$$ = CHARACTER_TYPE; current_type = CHARACTER_TYPE;} 
                            ;
vars :                      vars COMMA undef_variable {enqueue(&$$, $3);}
                            | undef_variable {initializeQueue(&$$); printf("queue init\n"); enqueue(&$$, $1);}
                            ;
undef_variable :            ID LPAREN dims RPAREN                                   {$$.name = $1; $$.isArray = 1; /*hashtbl_insert(hashtbl, $1, make_entry(current_type, 1), scope, current_type);*/}
                            | ID                                                    {$$.name = $1; $$.isArray = 0;  /*hashtbl_insert(hashtbl, $1, make_entry(current_type, 0), scope, current_type);*/}   
                            ;                                                       
dims :                      dims COMMA dim
                            | dim
dim :                       ICONST 
                            | ID                                                    //{hashtbl_insert(hashtbl, $1, NULL, scope, current_type);}
                            ;
fields :                    fields field
                            | field
                            ;
field :                     type vars {displayQueue(&$2); destroyQueue(&$2); printf("queue destroyed\n");}
                            | RECORD fields ENDREC vars {displayQueue(&$4); destroyQueue(&$4); printf("queue destroyed\n");}
                            ;
vals :                      vals COMMA ID value_list                                //{hashtbl_insert(hashtbl, $3, NULL, scope, current_type);}
                            | ID value_list                                         //{hashtbl_insert(hashtbl, $1, NULL, scope, current_type);}
                            ;
value_list :                DIVOP values DIVOP
                            ;
values :                    values COMMA value
                            | value
                            ;
value :                     repeat MULOP ADDOP constant
                            | repeat MULOP constant
                            | repeat MULOP STRING
                            | ADDOP constant
                            | constant
                            | STRING
                            ;
repeat :                    ICONST | %empty
                            ;
constant :                  ICONST | RCONST | LCONST | CCONST
                            ;
statements :                statements labeled_statement
                            | labeled_statement
                            ;
labeled_statement :         label statement
                            | statement
                            ;
label :                     ICONST
                            ;
statement :                 simple_statement
                            | compound_statement
                            ;
simple_statement :          assignment
                            | goto_statement
                            | if_statement
                            | subroutine_call
                            | io_statement
                            | CONTINUE
                            | RETURN
                            | STOP
                            ;
assignment :                variable ASSIGN expression
                            | variable ASSIGN STRING
                            ;
variable :                  variable COLON ID                                       //{hashtbl_insert(hashtbl, $3, NULL, scope, current_type);}
                            | variable LPAREN expressions RPAREN 
                            | ID                                                    //{hashtbl_insert(hashtbl, $1, NULL, scope, current_type);}
                            ;
expressions :               expressions COMMA expression 
                            | expression 
                            ;
expression :                expression OROP expression
                            | expression ANDOP expression
                            | expression RELOP expression
                            | expression ADDOP expression
                            | expression MULOP expression
                            | expression DIVOP expression
                            | expression POWEROP expression
                            | NOTOP expression 
                            | ADDOP expression
                            | variable
                            | constant
                            | LPAREN expression RPAREN
                            ;
goto_statement :            GOTO label
                            | GOTO ID COMMA LPAREN labels RPAREN                    //{hashtbl_insert(hashtbl, $2, NULL, scope, current_type);}
                            ;
labels :                    labels COMMA label
                            | label
                            ;
if_statement :              IF LPAREN expression RPAREN label COMMA label COMMA label
                            | IF LPAREN expression RPAREN simple_statement
                            ;
subroutine_call :           CALL variable
                            ;
io_statement :              READ read_list
                            | WRITE write_list
                            ;
read_list :                 read_list COMMA read_item
                            | read_item
                            ;
read_item :                 variable
                            | LPAREN read_list COMMA ID ASSIGN iter_space RPAREN    //{hashtbl_insert(hashtbl, $4, NULL, scope, current_type);}
                            ;
iter_space :                expression COMMA expression step
                            ;
step :                      COMMA expression
                            | %empty
                            ;
write_list :                write_list COMMA write_item
                            | write_item
                            ;
write_item :                expression
                            | LPAREN write_list COMMA ID ASSIGN iter_space RPAREN   //{hashtbl_insert(hashtbl, $4, NULL, scope, current_type);}
                            | STRING
                            ;
compound_statement :        branch_statement
                            | loop_statement
                            ;
branch_statement :          IF LPAREN expression RPAREN THEN body tail
                            ;
tail :                      ELSE body ENDIF
                            | ENDIF
                            ;
loop_statement :            DO ID ASSIGN iter_space body ENDDO                      //{hashtbl_insert(hashtbl, $2, NULL, scope, current_type);}
                            ;
subprograms :               subprograms subprogram
                            | %empty
                            ;
subprogram :                header body END
                            ;
header :                    type FUNCTION ID LPAREN formal_parameters RPAREN        //{hashtbl_insert(hashtbl, $3, NULL, scope, current_type);}
                            | SUBROUTINE ID LPAREN formal_parameters RPAREN         //{hashtbl_insert(hashtbl, $2, NULL, scope, current_type);}
                            | SUBROUTINE ID                                         //{hashtbl_insert(hashtbl, $2, NULL, scope, current_type);}
                            ;                             
formal_parameters :         type vars COMMA formal_parameters
                            | type vars
                            ;

%%

int main(int argc, char *argv[]) {
    int token;
    if(argc < 2) {
        printf("Please provide a filename as a command-line argument.\n");
        return 1;
    }
    
    yyin = fopen(argv[1], "r");
    if(yyin == NULL) {
        printf("Error opening the file.\n");
        return 1;
    }

    if(!(hashtbl = hashtbl_create(10, NULL))) {
        puts("Error, failed to initialize hashtable\n");
        return -1;
    }

    yyparse();
    
    fclose(yyin);
    hashtbl_destroy(hashtbl);
    return 0;
}

SymbolTableEntry* make_entry(DataType type, int isArray){
    SymbolTableEntry* entry = malloc(sizeof(SymbolTableEntry));
    entry->type = type;
    entry->isArray = isArray;

    return entry;
}

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

void addToSymbolTable(Queue* queue, DataType type) {
    while (!isEmpty(queue)) {
        SymbolTableEntry *dequeuedEntry = malloc(sizeof(SymbolTableEntry));
        *dequeuedEntry = dequeue(queue);
        hashtbl_insert(hashtbl, dequeuedEntry->name, dequeuedEntry, scope, type);
    }
}