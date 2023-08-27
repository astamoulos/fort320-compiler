#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"
#include "ast_printer.h"
#include "hashtbl.h"

/*Decl*/
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
/*statements*/
AST_Node *new_ast_assign_node(AST_Node *left, AST_Node *right){
	AST_Node_Assign *v = malloc(sizeof(AST_Node_Assign));

	v->type = ASSIGN_NODE;
	v->assign_var = left;
	v->assign_val = right;
}

AST_Node *new_ast_if_node(AST_Node *left, AST_Node *right){
	AST_Node_If *v = malloc(sizeof(AST_Node_If));

	v->type = IF_NODE;
	v->condition = left;
	v->branch = right;
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

AST_Node *new_ast_label_node(int label){
	AST_Node_Label *v = malloc(sizeof(AST_Node_Label));

	v->type = LABEL_NODE;
	v->label = label;

	return (struct AST_Node *) v;
}

AST_Node *new_ast_labeled_stm_node(AST_Node *label, AST_Node *stm){
	AST_Node_Labeled_Stm *v = malloc(sizeof(AST_Node_Labeled_Stm));

	v->type = LABELED_STM_NODE;
	v->label = label;
	v->stm = stm;

	return (struct AST_Node *) v;
}

AST_Node *new_ast_arithm_if_node(AST_Node *expr, AST_Node *label1, AST_Node *label2, AST_Node *label3){
	AST_Node_Arithm_If *v = malloc(sizeof(AST_Node_Arithm_If));

	v->type = ARITHM_IF_NODE;
	v->expr = expr;
	v->label1 = label1;
	v->label2 = label2;
	v->label3 = label3;

	return (struct AST_Node *) v;
}

AST_Node *new_ast_goto_node(AST_Node *label){
	AST_Node_Goto *v = malloc(sizeof(AST_Node_Goto));

	v->type = GOTO_NODE;
	v->label = label;

	return (struct AST_Node *) v;
}