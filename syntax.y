%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #define YYDEBUG 1

    extern FILE * yyin;
    extern int yylex();
    extern void yyerror(const char *err);
%}

%define parse.error verbose

%union{
    int intval;
    float floatval;
    char charval;
    char* strval;
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
%token ID "Identifier"

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

/*%token T_EOF 0 "end of file"*/

%left OROP
%left ANDOP
%precedence NOTOP
%nonassoc RELOP
%left ADDOP
%left MULOP DIVOP
%right POWEROP
%left COLON LPAREN RPAREN

%nonassoc REDUCE

%%
program :                   body END subprograms
body :                      declarations statements
declarations :              declarations type vars
                            | declarations RECORD fields ENDREC vars
                            | declarations DATA vals
                            | %empty
type :                      INTEGER | REAL | LOGICAL | CHARACTER
vars :                      vars COMMA undef_variable
                            | undef_variable
undef_variable :            ID LPAREN dims RPAREN
                            | ID
dims :                      dims COMMA dim
                            | dim
dim :                       ICONST | ID
fields :                    fields field
                            | field
field :                     type vars
                            | RECORD fields ENDREC vars
vals :                      vals COMMA ID value_list
                            | ID value_list
value_list :                DIVOP values DIVOP
values :                    values COMMA value
                            | value
value :                     repeat MULOP ADDOP constant
                            | repeat MULOP constant
                            | repeat MULOP STRING
                            | ADDOP constant
                            | constant
                            | STRING
repeat :                    ICONST | %empty
constant :                  ICONST | RCONST | LCONST | CCONST
statements :                statements labeled_statement
                            | labeled_statement
labeled_statement :         label statement
                            | statement
label :                     ICONST
statement :                 simple_statement
                            | compound_statement
simple_statement :          assignment
                            | goto_statement
                            | if_statement
                            | subroutine_call
                            | io_statement
                            | CONTINUE
                            | RETURN
                            | STOP
assignment :                variable ASSIGN expression
                            | variable ASSIGN STRING
variable :                  variable COLON ID
                            | variable LPAREN expressions RPAREN 
                            | ID 
expressions :               expressions COMMA expression 
                            | expression 
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
goto_statement :            GOTO label
                            | GOTO ID COMMA LPAREN labels RPAREN
labels :                    labels COMMA label
                            | label
if_statement :              IF LPAREN expression RPAREN label COMMA label COMMA label
                            | IF LPAREN expression RPAREN simple_statement
subroutine_call :           CALL variable
io_statement :              READ read_list
                            | WRITE write_list
read_list :                 read_list COMMA read_item
                            | read_item
read_item :                 variable
                            | LPAREN read_list COMMA ID ASSIGN iter_space RPAREN
iter_space :                expression COMMA expression step
step :                      COMMA expression
                            | %empty
write_list :                write_list COMMA write_item
                            | write_item
write_item :                expression
                            | LPAREN write_list COMMA ID ASSIGN iter_space RPAREN
                            | STRING
compound_statement :        branch_statement
                            | loop_statement
branch_statement :          IF LPAREN expression RPAREN THEN body tail
tail :                      ELSE body ENDIF
                            | ENDIF
loop_statement :            DO ID ASSIGN iter_space body ENDDO
subprograms :               subprograms subprogram
                            | %empty
subprogram :                header body END
header :                    type FUNCTION ID LPAREN formal_parameters RPAREN
                            | SUBROUTINE ID LPAREN formal_parameters RPAREN
                            | SUBROUTINE ID
formal_parameters :         type vars COMMA formal_parameters
                            | type vars

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

    yyparse();
    
    fclose(yyin);
    return 0;
}