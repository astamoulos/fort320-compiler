CC = gcc
CFLAGS =
LIBS = -lm

SRCS = lexer.l syntax.y hashtbl.c types.c ast.c ast_printer.c
OBJS = lex.yy.c syntax.tab.c hashtbl.o types.o ast.o ast_printer.o

.PHONY: all clean

all: compiler

compiler: $(OBJS)
	$(CC) $(OBJS) $(LIBS)

lex.yy.c: lexer.l
	flex $^

syntax.tab.c syntax.tab.h: syntax.y
	bison -v -d $^

%.o: %.c %.h
	$(CC) -c $<

clean:
	rm -f lex.yy.c syntax.tab.c syntax.tab.h syntax.output *.o lexer
