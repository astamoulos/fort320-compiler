lexer: syntax.tab.c lex.yy.c
	gcc syntax.tab.c lex.yy.c -lm

lex.yy.c: lexer.l
	flex lexer.l

syntax.tab.c: syntax.y
	bison -v -d syntax.y

clean:
	rm lex.yy.c a.out syntax.tab.c syntax.tab.h syntax.output
