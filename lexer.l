%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <math.h>
    #include "types.h"
    #include "ast.h"
    #include "ast_printer.h"
    #include "syntax.tab.h"

    #define flexdebug 0

    char str_buf[256];
    int error_counter = 0;

    void print_token(int token_id);
    int str_to_int(char *string);
    char handle_escape_sequence(char escape_char);
    float hex_to_float(char *str);
    float bin_to_float(char *str);
    float str_to_float(char *string);

    void yyerror(const char *err);
%}

%option case-insensitive
%option yylineno
%option noyywrap

%x STRINGS

ICONST      (0[bB][1][01]*)|(0[hH][1-9A-F][0-9A-F]*)|(0|[1-9][0-9]*)
BINCONST    (0[bB])(1[01]*)?\.(0*1+[01]*|0)
HEXCONST    0[Hh](0|[1-9A-F][0-9A-F]*)?\.(0*[1-9A-F]+[0-9A-F]*|0)?
EXP         E[+-]?(0|[1-9][0-9]*)
DECCONST    (0|[1-9][0-9]*)?(\.)(0*[1-9]+[0-9]*|0)?{EXP}?|(0|[1-9][0-9]*){EXP}
RCONST      {BINCONST}|{HEXCONST}|{DECCONST}
IDENTIFIER  [a-zA-Z][a-zA-Z0-9]*|_[a-zA-Z][a-zA-Z0-9]*((_?)[a-zA-Z0-9])*_

%%
"FUNCTION"      {print_token(FUNCTION); return FUNCTION;}
"SUBROUTINE"    {print_token(SUBROUTINE); return SUBROUTINE;}
"END"           {print_token(END); return END;}
"INTEGER"       {print_token(INTEGER); return INTEGER;}
"REAL"          {print_token(REAL); return REAL;}
"LOGICAL"       {print_token(LOGICAL); return LOGICAL;}
"CHARACTER"     {print_token(CHARACTER); return CHARACTER;}
"RECORD"        {print_token(RECORD); return RECORD;}
"ENDREC"        {print_token(ENDREC); return ENDREC;}        
"DATA"          {print_token(DATA); return DATA;}        
"CONTINUE"      {print_token(CONTINUE); return CONTINUE;}        
"GOTO"          {print_token(GOTO); return GOTO;}        
"CALL"          {print_token(CALL); return CALL;}        
"READ"          {print_token(READ); return READ;}        
"WRITE"         {print_token(WRITE); return WRITE;}        
"IF"            {print_token(IF); return IF;}        
"THEN"          {print_token(THEN); return THEN;}        
"ELSE"          {print_token(ELSE); return ELSE;}        
"ENDIF"         {print_token(ENDIF); return ENDIF;}        
"DO"            {print_token(DO); return DO;}        
"ENDDO"         {print_token(ENDDO); return ENDDO;}        
"STOP"          {print_token(STOP); return STOP;}        
"RETURN"        {print_token(RETURN); return RETURN;}     

{IDENTIFIER}    {print_token(ID); yylval.strval = strdup(yytext); return ID;} 
{ICONST}        {print_token(ICONST); yylval.val.ival = str_to_int(yytext); return ICONST;}
{RCONST}        {print_token(RCONST); yylval.val.fval = str_to_float(yytext); return RCONST;}

\"                  {BEGIN(STRINGS);}
<STRINGS>\"          {BEGIN(INITIAL); printf("Found string '%s' \n", str_buf); strcpy(str_buf, ""); return STRING;}
<STRINGS>(\\\n|\\\r\n) {/* Ignore escaped newline characters */}
<STRINGS>(\n|\r\n)   {yyerror("New line found without \\ \n");}
<STRINGS>\\.|[^|\\]  {
                        if (strlen(yytext) == 2) {
                            switch (yytext[1]) {
                                case 'n': strcat(str_buf, "\n"); break;
                                case 'f': strcat(str_buf, "\f"); break;
                                case 't': strcat(str_buf, "\t"); break;
                                case 'r': strcat(str_buf, "\r"); break;
                                case 'b': strcat(str_buf, "\b"); break;
                                case 'v': strcat(str_buf, "\v"); break;
                                default: strcat(str_buf, &yytext[1]); break;
                            }
                        } else {
                            strcat(str_buf, yytext);
                        }
                    }
<STRINGS><<EOF>>     {yyerror("End of string without closing it\n");}
<STRINGS>.           {yyerror("Found unrecognized character\n");}


"$".*               {printf("Comment found\n");}

'[ -~]'         {print_token(CCONST); yylval.val.cval = yytext[1]; return CCONST;} 
'\\[nftrbv]'    {print_token(CCONST); yylval.val.cval = handle_escape_sequence(yytext[2]); return CCONST;}   

".TRUE."        {print_token(LCONST); return LCONST;}
".FALSE."       {print_token(LCONST); return LCONST;}

".OR."          {print_token(OROP); return OROP;}
".AND."         {print_token(ANDOP); return ANDOP;}
".NOT."         {print_token(NOTOP); return NOTOP;}
".GT."          {print_token(RELOP); yylval.intval = GREATER; return RELOP;}
".GE."          {print_token(RELOP); yylval.intval = GREATER_EQUAL; return RELOP;}
".LT."          {print_token(RELOP); yylval.intval = LESS; return RELOP;}
".LE."          {print_token(RELOP); yylval.intval = LESS_EQUAL; return RELOP;}
".EQ."          {print_token(RELOP); yylval.intval = EQUAL; return RELOP;}
".NE."          {print_token(RELOP); yylval.intval = NOT_EQUAL; return RELOP;}
"+"             {print_token(ADDOP); yylval.intval = ADD; return ADDOP;}
"-"             {print_token(ADDOP); yylval.intval = SUB; return ADDOP;}
"*"             {print_token(MULOP); return MULOP;}
"/"             {print_token(DIVOP); return DIVOP;}
"**"            {print_token(POWEROP); return POWEROP;}

"("             {print_token(LPAREN); return LPAREN;}
")"             {print_token(RPAREN); return RPAREN;}
","             {print_token(COMMA); return COMMA;}
"="             {print_token(ASSIGN); return ASSIGN;}
":"             {print_token(COLON); return COLON;}

[ \t]           { }
[\n]            { }
[\r\n]          { }
<<EOF>>         {print_token(0); return 0;}
                
.               {yyerror("Unrecognised Charachter\n");} 

%% 
/*
int main(int argc, char *argv[]) {
    int token;
    if(argc > 1) {
        yyin = fopen(argv[1], "r");
        if(yyin == NULL) {
            perror("Error opening file\n");
            return -1;
        }
    }
    do {
        token = yylex();
    }while(token != 0);
    
    fclose(yyin);
    yyterminate();
}
*/
int str_to_int(char *string) {
    if(strncmp(string, "0h", 2) == 0 || strncmp(string, "0H", 2) == 0)
        return strtoll(&string[2], NULL, 16);
    else if(strncmp(string, "0b", 2) == 0 || strncmp(string, "0B", 2) == 0)
        return strtoll(&string[2], NULL, 2);
    else    
        return atoi(string);
}

void print_token(int token_id) {
    if(!flexdebug)
        return;

    if(token_id == ICONST)
        printf("LINE: %d | Found token %-10s | with ID: %d | BASE 10: %d\n", yylineno, yytext, token_id, str_to_int(yytext));
    else if(token_id == RCONST)
        printf("LINE: %d | Found token %-10s | with ID: %d | BASE 10: %f\n", yylineno, yytext, token_id, str_to_float(yytext));
    else if(token_id == 0)
        printf("LINE: %d | Found token %-10s | with ID: %d\n", yylineno, "eof", 0);
    else
        printf("LINE: %d | Found token %-10s | with ID: %d\n", yylineno, yytext, token_id);
    return ; 
}

void yyerror(const char *err){
    error_counter++;

    printf("[ERROR - LINE %d] %s\n", yylineno, err);
    if(error_counter == 5){
        printf("MAXIMUM ERRORS FOUND\n");
        exit(EXIT_FAILURE);
    }

    yyless(1);
}

char handle_escape_sequence(char escape_char) {
    switch (escape_char) {
        case 'n':
            return '\n';
        case 'f':
            return '\f';
        case 'r':
            return '\r';
        case 't':
            return '\t';
        case 'b':
            return '\b';
        case 'v':
            return '\v';
    }
}

float str_to_float(char *string) {
    if(strncmp(string, "0h", 2) == 0 || strncmp(string, "0H", 2) == 0)
        return hex_to_float(string);
    else if(strncmp(string, "0b", 2) == 0 || strncmp(string, "0B", 2) == 0)
        return bin_to_float(string);
    else    
        return atof(string);
}

float bin_to_float(char *str) {
    float number = 0.0;
    int i, length_real;
    char *character;

    character = strchr(str, '.');
    length_real = strlen(character) - 1;
    number = (int)strtol(&str[2], &character, 2);
    
    for(i = 1; i < length_real+1; i++) {
        number += (character[i] - '0') * (1/pow(2,i));
    }
    return number;
}

float hex_to_float(char *str) {
    float number = 0.0;
    int i, length_real;
    char *character;

    character = strchr(str, '.');
    length_real = strlen(character) - 1;

    number = (int)strtol(&str[2], &character, 16);
    for(i = 1; i < length_real + 1; i++) {
        if(character[i] <= '9')
			number += (character[i] - '0') * (1/pow(16,i));
		else if(character[i]  <= 'Z'){
			number += (character[i] + 10 - 'A') * (1/pow(16,i)); 
	    }
		else{
			number += (character[i] + 10 - 'a') * (1/pow(16,i));
		}
    }
    return number;
}