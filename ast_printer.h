#ifndef AST_PRINTER_H
#define AST_PRINTER_H

void print_indent(int depth);
void ast_print_node(AST_Node *node, int indent);

#endif