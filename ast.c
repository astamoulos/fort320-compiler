#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"

AST_Node *new_ast_decl_node(DataType data_type, Node **names){
    // allocate memory
	AST_Node_Decl *v = malloc (sizeof (AST_Node_Decl));
	
	// set entries
	v->type = DECL_NODE;
	v->data_type = data_type;
	//v->names = names;
	//v->names_count = names_count;
	
	// return type-casted result
	return (struct AST_Node *) v;
}