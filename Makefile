lexer: syntax.tab.c lex.yy.c hashtbl.o types.o ast.o
	gcc syntax.tab.c lex.yy.c hashtbl.o types.o ast.o -lm

lex.yy.c: lexer.l
	flex lexer.l

syntax.tab.c: syntax.y
	bison -v -d syntax.y

hashtbl.o: hashtbl.c hashtbl.h
	gcc -o hashtbl.o -c hashtbl.c

types.o: types.c types.h
	gcc -o types.o -c types.c

ast.o: ast.c ast.h
	gcc -o ast.o -c ast.c

clean:
	rm lex.yy.c syntax.tab.c syntax.tab.h syntax.output *.o a.out 
