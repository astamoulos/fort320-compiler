#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"
#include "ast_printer.h"

AST_Node *new_ast_decl_list_node(AST_Node*  left, AST_Node* right){
    // allocate memory
	AST_Node_Decl_List *v = malloc (sizeof (AST_Node_Decl_List));
	v->type = DECL_LIST_NODE;
	v->left = left;
	v->right = right;
	// return type-casted result
	return (struct AST_Node *) v;
}

AST_Node *new_ast_decl_node(DataType data_type, Node *names){
    // allocate memory
	AST_Node_Decl *v = malloc (sizeof (AST_Node_Decl));
	
	// set entries
	v->type = DECL_NODE;
	v->data_type = data_type;
	v->names = names;
	//v->names_count = names_count;
	
	// return type-casted result
	return (struct AST_Node *) v;
}
/* Expressions */
AST_Node *new_ast_arithm_node(enum Arithm_op op, AST_Node *left, AST_Node *right){
	// allocate memory
	AST_Node_Arithm *v = malloc (sizeof (AST_Node_Arithm));
	
	// set entries
	v->type = ARITHM_NODE;
	v->op = op;
	v->left = left;
	v->right = right;
	
	// return type-casted result
	return (struct AST_Node *) v;
}

AST_Node *new_ast_bool_node(enum Bool_op op, AST_Node *left, AST_Node *right){
	// allocate memory
	AST_Node_Bool *v = malloc (sizeof (AST_Node_Bool));
	
	// set entries
	v->type = BOOL_NODE;
	v->op = op;
	v->left = left;
	v->right = right;
	
	// return type-casted result
	return (struct AST_Node *) v;
}

AST_Node *new_ast_rel_node(enum Rel_op op, AST_Node *left, AST_Node *right){
	// allocate memory
	AST_Node_Rel *v = malloc (sizeof (AST_Node_Rel));
	
	// set entries
	v->type = REL_NODE;
	v->op = op;
	v->left = left;
	v->right = right;
	
	// return type-casted result
	return (struct AST_Node *) v;
}

AST_Node *new_ast_const_node(int const_type, Value val){
	//allcate memory
	AST_Node_Const *v = malloc (sizeof (AST_Node_Const));

	//set entries
	v->type = CONST_NODE;
	v->const_type = const_type;
	v->val = val;

	// return type-casted result
	return (struct AST_Node *) v;
}

/*
AST_Node *new_ast_equ_node(enum Equ_op op, AST_Node *left, AST_Node *right){
	// allocate memory
	AST_Node_Equ *v = malloc (sizeof (AST_Node_Equ));
	
	// set entries
	v->type = EQU_NODE;
	v->op = op;
	v->left = left;
	v->right = right;
	
	// return type-casted result
	return (struct AST_Node *) v;	
}
*/


AST_Node *new_ast_ref_node(struct hashnode_s *entry){
	// allocate memory
	AST_Node_Ref *v = malloc (sizeof (AST_Node_Ref));
	
	// set entries
	v->type = REF_NODE;
	v->entry = entry;

	// return type-casted result
	return (struct AST_Node *) v;	
}


/* Tree Traversal */

void ast_print_node(AST_Node *node, int indent){
	/* temp nodes */
	AST_Node_Decl_List *temp_decl_list;
	AST_Node_Decl *temp_decl;
	AST_Node_Const *temp_const;
	AST_Node_If *temp_if;
	AST_Node_Assign *temp_assign;
	AST_Node_Simple *temp_simple;
	AST_Node_Incr *temp_incr;
	AST_Node_Func_Call *temp_func_call;
	AST_Node_Arithm *temp_arithm;
	AST_Node_Bool *temp_bool;
	AST_Node_Rel *temp_rel;
	//AST_Node_Equ *temp_equ;
	AST_Node_Func_Decl *temp_func_decl;
	AST_Node_Return *temp_return;
	
	switch(node->type){
		case BASIC_NODE:
			printf("Basic Node\n");
			break;
		case DECL_LIST_NODE:
			temp_decl_list = (struct AST_Node_Decl_List *) node;
			if(temp_decl_list->left == NULL){
				print_indent(indent);
				printf("decllist(empty)\n");
				return;
			}
			print_indent(indent);
			printf("decllist\n");
			indent++;
			ast_print_node(temp_decl_list->left, indent);
			ast_print_node(temp_decl_list->right, indent);
			break;
		case DECL_NODE:
			temp_decl = (struct AST_Node_Decl *) node;
			print_indent(indent);
  			printf("decl\n");
			print_indent(indent + 1);
			printf("type:");
			switch (temp_decl->data_type) {
				case INT_TYPE:
					printf("int\n");
					break;
				case REAL_TYPE:
					printf("real\n");
					break;
				case LOGICAL_TYPE:
					printf("logical\n");
					break;
				case CHARACTER_TYPE:
					printf("char'n");
					break;
				case RECORD_TYPE:
					printf("record\n");
					break;
			}
			print_indent(indent + 1);
			Node *curr = temp_decl->names;
			while (curr != NULL) {
				printf("%s", curr->data.name);
				printf(" ");
				curr = curr->next;
			}
			printf("\n");
			//printf("Declaration Node of data-type %d for names\n", temp_decl->data_type);
			break;
		default: /* wrong choice case */
			fprintf(stderr, "Error in node selection!\n");
			exit(1);
	}
}