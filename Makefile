lexer: syntax.tab.c lex.yy.c hashtbl.o
	gcc syntax.tab.c lex.yy.c hashtbl.o -lm

lex.yy.c: lexer.l
	flex lexer.l

syntax.tab.c: syntax.y
	bison -v -d syntax.y

hashtbl.o: hashtbl.c hashtbl.h
	gcc -o hashtbl.o -c hashtbl.c

clean:
	rm lex.yy.c a.out syntax.tab.c syntax.tab.h syntax.output
