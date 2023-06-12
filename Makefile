lexer: syntax.tab.c lex.yy.c hashtbl.o types.o
	gcc syntax.tab.c lex.yy.c hashtbl.o types.o -lm

lex.yy.c: lexer.l
	flex lexer.l

syntax.tab.c: syntax.y
	bison -v -d syntax.y

hashtbl.o: hashtbl.c hashtbl.h
	gcc -o hashtbl.o -c hashtbl.c

types.o: types.c types.h
	gcc -o types.o -c types.c

clean:
	rm lex.yy.c a.out syntax.tab.c syntax.tab.h syntax.output hashtbl.o types.o