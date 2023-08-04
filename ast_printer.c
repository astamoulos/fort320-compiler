#include <stdio.h>
#include "ast.h"
#include "ast_printer.h"

#define NUM_SYMS 2
static char syms[NUM_SYMS] = { '|', '|' };

void print_indent(int depth) {
  int current_char = 0;
  if (depth > 0) {
    for (int i = 0; i < depth; i++) {
//      printf("%c  ", syms[current_char]);
      printf("|  ");
      current_char = (current_char + 1) % NUM_SYMS;
    }
  }
  printf("+-");
}

