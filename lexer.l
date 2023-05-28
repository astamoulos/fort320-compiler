%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    //#include "lexer.h"
    #include "syntax.tab.h"

    char str_buf[256];
    int error_counter = 0;

    void print_token(int token_id);
    int str_to_int(char *string);
    char handle_escape_sequence(char escape_char);

    void yyerror(const char *err);
%}

%option case-insensitive
%option yylineno
%option noyywrap

%x STRING

ICONST      (0[bB][1][01]*)|(0[hH][1-9A-F][0-9A-F]*)|(0|[1-9][0-9]*)
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
{ICONST}        {print_token(ICONST); yylval.intval = str_to_int(yytext); return ICONST;}

\"                  {BEGIN(STRING);}
<STRING>\"          {BEGIN(INITIAL); printf("Found string '%s' \n", str_buf); strcpy(str_buf, ""); return STRING;}
<STRING>(\\\n|\\\r\n) {/* Ignore escaped newline characters */}
<STRING>(\n|\r\n)   {yyerror("New line found without \\ \n");}
<STRING>\\.|[^|\\]  {
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
<STRING><<EOF>>     {yyerror("End of string without closing it\n");}
<STRING>.           {yyerror("Found unrecognized character\n");}


"$".*               {printf("Comment found\n");}

'[ -~]'         {print_token(CCONST); yylval.charval = yytext[1]; return CCONST;} 
'\\[nftrbv]'    {print_token(CCONST); yylval.charval = handle_escape_sequence(yytext[2]); return CCONST;}   

".TRUE."        {print_token(LCONST); return LCONST;}
".FALSE."       {print_token(LCONST); return LCONST;}

".OR."          {print_token(OROP); return OROP;}
".AND."         {print_token(ANDOP); return ANDOP;}
".NOT."         {print_token(NOTOP); return NOTOP;}
".GT."|".GE."|".LT."|".LE."|".EQ."|".NE."  {print_token(RELOP); return RELOP;}
"+"|"-"         {print_token(ADDOP); return ADDOP;}
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
<<EOF>>         {print_token(EOF); return 0;}
                
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
    if(token_id == ICONST)
        printf("LINE: %d | Found token %-10s | with ID: %d | BASE 10: %d\n", yylineno, yytext, token_id, str_to_int(yytext));
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