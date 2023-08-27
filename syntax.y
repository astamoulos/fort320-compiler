%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "hashtbl.h"
    #include "ast.h"
    #include "ast_printer.h"
    #define YYDEBUG 1

    extern FILE * yyin;
    extern int yylex();
    extern void yyerror(const char *err);
    //SymbolTableEntry* make_entry(DataType type, int isArray);
    void addToSymbolTable(Node* list, DataType type, Node* fields);
    void addFieldsToSymbolTable(struct hashnode_s** curr_field, Node* fields);
    void free_fields(Node* fields);
    AST_Node* ast;

    HASHTBL *hashtbl;
    int scope = 0;
    Node *test;
%}

%define parse.error verbose

%union{
    Value val;

    int intval;
    float floatval;
    char charval;
    char* strval;
    
    DataType basictype;
    UndefVar undef_var;
    struct hashnode_s* symbol;
    struct Node *list;
    AST_Node* node;
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
%token <val> ICONST "ICONST"
%token <val> RCONST "RCONST"
%token <val> LCONST "LCONST"
%token <val> CCONST "CCONST"

//Operators
%token OROP ".OR."
%token ANDOP ".AND."
%token NOTOP ".NOT."
%token <intval> RELOP
%token <intval> ADDOP "+ or -" 
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
%type <node> declarations expression constant variable assignment simple_statement if_statement label statement
%type <node> labeled_statement goto_statement branch_statement tail body compound_statement

%%
program :                   body END subprograms
                            ;
body :                      declarations statements {ast_print_node($1, 0);}
                            ;
declarations :              declarations type vars  {$$ = new_ast_decl_list_node($1 ,new_ast_decl_node($2, $3)); addToSymbolTable($3, $2, NULL); /*freeList(&$3);*/}
                            | declarations RECORD fields ENDREC vars                {displayList($3);  displayList($5); addToSymbolTable($5, RECORD_TYPE, $3); freeList(&$3); freeList(&$5); printf("list record destroyed\n");}
                            | declarations DATA vals
                            | %empty    {$$ = new_ast_decl_list_node(NULL, NULL);}
                            ;
type :                      INTEGER                                                 {$$ = INT_TYPE;} 
                            | REAL                                                  {$$ = REAL_TYPE;} 
                            | LOGICAL                                               {$$ = LOGICAL_TYPE;} 
                            | CHARACTER                                             {$$ = CHARACTER_TYPE;} 
                            ;
vars :                      vars COMMA undef_variable                               {insertAtEnd(&$$, $3);}
                            | undef_variable                                        {$$ = createNode($1);}
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
constant :                  ICONST      {$$ = new_ast_const_node(INT_TYPE, $1);}
                            | RCONST    {$$ = new_ast_const_node(REAL_TYPE, $1);}
                            | LCONST    {$$ = new_ast_const_node(INT_TYPE, $1);}
                            | CCONST    {$$ = new_ast_const_node(CHARACTER_TYPE, $1);}
                            ;
statements :                statements labeled_statement
                            | labeled_statement
                            ;
labeled_statement :         label statement {$$ = new_ast_labeled_stm_node($1, $2);}
                            | statement {$$ = $1;}
                            ;
label :                     ICONST      {$$ = new_ast_label_node($1.ival);}
                            ;
statement :                 simple_statement        {$$ = $1;}
                            | compound_statement    {$$ = $1;}
                            ;
simple_statement :          assignment          {$$ = $1;}
                            | goto_statement    {$$ = $1;}
                            | if_statement      {$$ = $1;}
                            | subroutine_call   {}
                            | io_statement      {}
                            | CONTINUE          {}
                            | RETURN            {}
                            | STOP              {}
                            ;
assignment :                variable ASSIGN expression {$$ = new_ast_assign_node($1, $3);}
                            | variable ASSIGN STRING   {printf("string\n");}
                            ;
variable :                  variable COLON ID       {printf("struct\n");}                                //{hashtbl_insert(hashtbl, $3, NULL, scope, current_type);}
                            | variable LPAREN expressions RPAREN    {printf("array\n");}
                            | ID                                    {$$ = new_ast_ref_node(hashtbl_find(hashtbl, $1, scope));}
                            ;
expressions :               expressions COMMA expression 
                            | expression 
                            ;
expression :                expression OROP expression      {$$ = new_ast_bool_node(OR, $1, $3);}
                            | expression ANDOP expression   {$$ = new_ast_bool_node(AND, $1, $3);}
                            | expression RELOP expression   {$$ = new_ast_rel_node($2, $1, $3);}
                            | expression ADDOP expression   {$$ = new_ast_arithm_node($2, $1, $3); }
                            | expression MULOP expression   {$$ = new_ast_arithm_node(MUL, $1, $3);}
                            | expression DIVOP expression   {$$ = new_ast_arithm_node(DIV, $1, $3);}
                            | expression POWEROP expression {$$ = new_ast_arithm_node(POW, $1, $3);}
                            | NOTOP expression              {$$ = new_ast_bool_node(NOT, $2, NULL);}
                            | ADDOP expression              {$$ = new_ast_arithm_node($1, $2, NULL);}
                            | variable                      {$$ = $1;}
                            | constant                      {$$ = $1;}
                            | LPAREN expression RPAREN      {$$ = $2;}
                            ;
goto_statement :            GOTO label                      {$$ = new_ast_goto_node($2);}
                            | GOTO ID COMMA LPAREN labels RPAREN     {}               //{hashtbl_insert(hashtbl, $2, NULL, scope, current_type);}
                            ;
labels :                    labels COMMA label
                            | label
                            ;
if_statement :              IF LPAREN expression RPAREN label COMMA label COMMA label {$$ = new_ast_arithm_if_node($3, $5, $7, $9);}
                            | IF LPAREN expression RPAREN simple_statement  {$$ = new_ast_if_node($3, $5);}
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
compound_statement :        branch_statement {$$ = $1;}
                            | loop_statement {}
                            ;
branch_statement :          IF LPAREN expression RPAREN THEN body tail {$$ = new_ast_branch_node($3, $6, $7);}
                            ;
tail :                      ELSE body ENDIF {$$ = $2;}
                            | ENDIF         {$$ = NULL;}
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
    //hashtbl_print(hashtbl);
    hashtbl_destroy(hashtbl);
    return 0;
}

void addToSymbolTable(Node* list, DataType type, Node* fields) {
    Node* curr = list;
    struct hashnode_s* node;

    while (curr != NULL) {
        node = hashtbl_insert(hashtbl, strdup(curr->data.name), NULL, scope, type, curr->data.isArray);
        
        if (fields) {
            printf("Adding fields\n");
            addFieldsToSymbolTable(&(node->fields), fields);
        }

        curr = curr->next; // Move to the next node in the list
    }
    Node* temp = fields;
    while(temp){
        free(temp->data.name);
        free_fields(temp->fields);
        temp = temp->next;
    }
}

void free_fields(Node* fields){
    Node* current = fields;
    Node* next;
    
    while (current != NULL) {
        next = current->next;
        free(current->data.name);
        current = next;
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
        new_field->fields = NULL;

        *curr_field = new_field;
        curr_field = &(new_field->next);

        if (temp_fields->fields) {
            printf("Adding nested fields\n");
            addFieldsToSymbolTable(&(new_field->fields), temp_fields->fields);
        }

        temp_fields = temp_fields->next; // Move to the next field
    }
}