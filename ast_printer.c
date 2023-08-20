#include <stdio.h>
#include "ast.h"
#include "ast_printer.h"
#include "hashtbl.h"

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
	AST_Node_Ref *temp_ref;
	//AST_Node_Equ *temp_equ;
	AST_Node_Func_Decl *temp_func_decl;
	AST_Node_Return *temp_return;
	AST_Node_Label *temp_label;
	AST_Node_Labeled_Stm *temp_labeled_stm;
	AST_Node_Arithm_If *temp_arithm_if;

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
		case ARITHM_NODE:
			temp_arithm = (struct AST_Node_Arithm *) node;
			print_indent(indent);
			switch (temp_arithm->op){
			case ADD:
				/* code */
				printf("ADD\n");
				break;
			case SUB:
				/* code */
				printf("SUB\n");
				break;
			case MUL:
				/* code */
				printf("MUL\n");
				break;
			case DIV:
				/* code */
				printf("DIV\n");
				break;
			case POW:
				/* code */
				printf("POW\n");
				break;
			default:
				break;
			}
			indent ++;
			ast_print_node(temp_arithm->left, indent);
			ast_print_node(temp_arithm->right, indent);
			break;
		case BOOL_NODE:
			temp_bool = (struct AST_Node_Bool *) node;
			print_indent(indent);
			switch (temp_bool->op){
			case OR:
				printf("OR");
				break;
			case AND:
				printf("AND");
				break;
			case NOT:
				printf("NOT");
				break;
			default:
				break;
			}
			printf("\n");
			indent ++;
			ast_print_node(temp_bool->left, indent);
			if(temp_bool->op != NOT)
				ast_print_node(temp_bool->right, indent);
			break;
		case REL_NODE:
			temp_rel = (struct AST_Node_Rel *)node;
			print_indent(indent);
			switch (temp_rel->op){
			case GREATER:
				printf("GT");
				break;
			case GREATER_EQUAL:
				printf("GE");
				break;
			case LESS:
				printf("LT");
				break;
			case LESS_EQUAL:
				printf("LE");
				break;
			case EQUAL:
				printf("EQ");
				break;
			case NOT_EQUAL:
				printf("NE");
			default:
				break;
			}
			printf("\n");
			indent ++;
			ast_print_node(temp_rel->left, indent);
			ast_print_node(temp_rel->right, indent);
			break;
		case CONST_NODE:
			temp_const = (struct AST_Node_Const *) node;
			print_indent(indent);
			printf("const ");
			switch (temp_const->const_type){
			case INT_TYPE:
				printf("%d", temp_const->val.ival);
				break;
			case REAL_TYPE:
				printf("%lf", temp_const->val.fval);
				break;
			case CHARACTER_TYPE:
				printf("%C", temp_const->val.cval);
				break;
			default:
				break;
			}
			printf("\n");
			break;
		case REF_NODE:
			temp_ref = (struct AST_Node_Ref *) node;
			print_indent(indent);
			printf("id ");
			printf("%s\n", temp_ref->entry->key);
			break;
		case ASSIGN_NODE:
			temp_assign = (struct AST_Node_Assign *) node;
			print_indent(indent);
			printf("=\n");
			indent++;
			ast_print_node(temp_assign->assign_var, indent);
			ast_print_node(temp_assign->assign_val, indent);
			break;
		case IF_NODE:
			temp_if = (struct AST_Node_If *) node;
			print_indent(indent);
			printf("if\n");
			indent++;
			ast_print_node(temp_if->condition, indent);
			ast_print_node(temp_if->branch, indent);
			break;
		case LABEL_NODE:
			temp_label = (struct AST_Node_Label *) node;
			print_indent(indent);
			printf("label %d\n", temp_label->label);
			break;
		case LABELED_STM_NODE:
			temp_labeled_stm = (struct AST_Node_Labeled_Stm *) node;
			print_indent(indent);
			printf("labeled_stm\n");
			indent++;
			ast_print_node(temp_labeled_stm->label, indent);
			ast_print_node(temp_labeled_stm->stm, indent);
			break;
		case ARITHM_IF_NODE:
			temp_arithm_if = (struct AST_Node_Arithm_If *) node;
			print_indent(indent);
			printf("arithm_if\n");
			indent++;
			ast_print_node(temp_arithm_if->expr, indent);
			ast_print_node(temp_arithm_if->label1, indent);
			ast_print_node(temp_arithm_if->label2, indent);
			ast_print_node(temp_arithm_if->label3, indent);
			break;
		default: /* wrong choice case */
			fprintf(stderr, "Error in node selection %d!\n", node->type);
			//exit(1);
	}
}