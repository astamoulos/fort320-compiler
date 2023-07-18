%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "hashtbl.h"
    
    #define YYDEBUG 1

    extern FILE * yyin;
    extern int yylex();
    extern void yyerror(const char *err);
    //SymbolTableEntry* make_entry(DataType type, int isArray);
    void addToSymbolTable(Node** list, DataType type, Node* fields);
    void addFieldsToSymbolTable(struct hashnode_s** curr_field, Node* fields);

    HASHTBL *hashtbl;
    int scope = 0;
%}

%define parse.error verbose

%union{
    int intval;
    float floatval;
    char charval;
    char* strval;
    
    DataType basictype;
    UndefVar undef_var;
    Node *list;
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
%type <list> vars fields field

%%
program :                   body END subprograms
                            ;
body :                      declarations statements
                            ;
declarations :              declarations type vars                                  {displayList($3); addToSymbolTable(&$3, $2, NULL); freeList(&$3); printf("list destroyed\n");}
                            | declarations RECORD fields ENDREC vars                {displayList($3);  displayList($5); addToSymbolTable(&$5, RECORD_TYPE, $3); freeList(&$3); freeList(&$5); printf("list record destroyed\n");}
                            | declarations DATA vals
                            | %empty
                            ;
type :                      INTEGER                                                 {$$ = INT_TYPE;} 
                            | REAL                                                  {$$ = REAL_TYPE;} 
                            | LOGICAL                                               {$$ = LOGICAL_TYPE;} 
                            | CHARACTER                                             {$$ = CHARACTER_TYPE;} 
                            ;
vars :                      vars COMMA undef_variable                               {insertAtEnd(&$$, $3);}
                            | undef_variable                                        {$$ = createNode($1); }
                            ;
undef_variable :            ID LPAREN dims RPAREN                                   {$$.name = $1; $$.isArray = 1;}
                            | ID                                                    {$$.name = $1; $$.isArray = 0;}   
                            ;                                                       
dims :                      dims COMMA dim
                            | dim
dim :                       ICONST 
                            | ID                                                    //{hashtbl_insert(hashtbl, $1, NULL, scope, current_type);}
                            ;
fields :                    fields field                                            {concatLists(&$$, $2);}
                            | field                                                 {$$ = $1;}         
                            ;
field :                     type vars                                               {updateType($2, $1); $$ = $2;}
                            | RECORD fields ENDREC vars                             {concatLists(&$4->fields, $2); updateType($4, RECORD_TYPE);$$ = $4;}
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
    hashtbl_print(hashtbl);
    hashtbl_destroy(hashtbl);
    return 0;
}

void addToSymbolTable(Node** list, DataType type, Node* fields) {
    Node* curr = *list;
    struct hashnode_s* node;

    while (curr != NULL) {
        node = hashtbl_insert(hashtbl, curr->data.name, NULL, scope, type, curr->data.isArray);
        
        if (fields) {
            printf("Adding fields\n");
            addFieldsToSymbolTable(&(node->fields), fields);
        }

        curr = curr->next; // Move to the next node in the list
    }
}

void addFieldsToSymbolTable(struct hashnode_s** curr_field, Node* fields) {
    Node* temp_fields = fields;

    while (temp_fields) {
        UndefVar field = temp_fields->data;
        struct hashnode_s* new_field = malloc(sizeof(struct hashnode_s));
        new_field->key = strdup(field.name);
        new_field->isArray = field.isArray;
        new_field->type = field.type;
        new_field->next = NULL;
        //new_field->fields = NULL;

        *curr_field = new_field;
        curr_field = &(new_field->next);

        if (temp_fields->fields) {
            printf("Adding nested fields\n");
            addFieldsToSymbolTable(&(new_field->fields), temp_fields->fields);
        }

        temp_fields = temp_fields->next; // Move to the next field
    }
}