#ifndef AST_H
#define AST_H
#include "types.h"
/* ---------------------NODE TYPES-------------------------- */

typedef enum Node_Type {
	BASIC_NODE,  // no special usage (for roots only)
	// declarations
	DECL_LIST_NODE,
	DECL_NODE,   // declaration
	CONST_NODE,  // constant
	STMS_NODE,	 // statements
	// statements
	ARITHM_IF_NODE,
	IF_NODE,     // if statement
	ELSIF_NODE,  // else if branch
	FOR_NODE,    // for statement
	WHILE_NODE,  // while statement
	ASSIGN_NODE, // assigment
	SIMPLE_NODE, // continue, break and "main" return statements
	INCR_NODE,   // increment statement (non-expression one)
	FUNC_CALL,   // function call
	// expressions
	ARITHM_NODE, // arithmetic expression
	BOOL_NODE,   // boolean expression
	REL_NODE,    // relational expression
	EQU_NODE,    // equality expression
	REF_NODE,	 // identifier
	// functions
	FUNC_DECL,   // function declaration
	RETURN_NODE, // return statement of functions
	// other
	LABEL_NODE,
	LABELED_STM_NODE,
	GOTO_NODE,
	GOTO_CALC_NODE,
	BRANCH_NODE,
	BODY_NODE,
}Node_Type;

/* --------------------OPERATOR TYPES----------------------- */

typedef enum Arithm_op{
	ADD,  // + operator
	SUB,  // - operator
	MUL,  // * operator
	DIV , // / operator
	INC, // ++ operator
	DEC, // -- operator
	POW, // ** operator
}Arithm_op;

typedef enum Bool_op{
	OR,  // || operator
	AND, // && operator
	NOT  // ! operator
}Bool_op;

typedef enum Rel_op{
	GREATER,        // > operator
	LESS,           // < operator
	GREATER_EQUAL,  // >= operator
	LESS_EQUAL,     // <= operator
	EQUAL,    		// == operator
	NOT_EQUAL 		// != operator
}Rel_op;

/*
typedef enum Equ_op{
	EQUAL,    // == operator
	NOT_EQUAL // != operator
}Equ_op;
*/

/* -------------------HELP STRUCTURES----------------------- */

/* Types of values that we can have in constants */
typedef union Value{
	int ival;
	double fval;
	char cval;
	char *sval;
}Value;

/* -----------------------AST NODES------------------------- */

/* The basic node */
typedef struct AST_Node{
	enum Node_Type type; // node type
	struct AST_Node *left;  // left child
	struct AST_Node *right; // right child
}AST_Node;

/* Declarations */
typedef struct AST_Node_Decl_List{
	enum Node_Type type; // node type
	
	struct AST_Node *left;
	struct AST_Node *right;
}AST_Node_Decl_List;

typedef struct AST_Node_Decl{
	enum Node_Type type; // node type
	
	// data type
	int data_type;
	
	// symbol table entries of the variables
	Node* names;
}AST_Node_Decl;

typedef struct AST_Node_Const{
	enum Node_Type type; // node type
	
	// data type
	int const_type;
	
	// constant value
	Value val;
}AST_Node_Const;

/* Statements */
typedef struct AST_Node_If{
	enum Node_Type type; // node type
	
	// condition
	struct AST_Node *condition;
	
	// if branch
	struct AST_Node *branch;

}AST_Node_If;

typedef struct AST_Node_Elsif{
	enum Node_Type type; // node type
	
	// condition
	struct AST_Node *condition;
	
	// branch
	struct AST_Node *elsif_branch;
}AST_Node_Elsif;

typedef struct AST_Node_For{
	enum Node_Type type; // node type
	
	// initialization
	struct AST_Node *initialize;
	
	// condition
	struct AST_Node *condition;
	
	// incrementation
	struct AST_Node *increment;
	
	// branch
	struct AST_Node *for_branch;
}AST_Node_For;

typedef struct AST_Node_While{
	enum Node_Type type; // node type
	
	// condition
	struct AST_Node *condition;
	
	// branch
	struct AST_Node *while_branch;
}AST_Node_While;

typedef struct AST_Node_Assign{
	enum Node_Type type; // node type
	
	// variable
	struct AST_Node *assign_var;
	
	// assignment value
	struct AST_Node *assign_val;
}AST_Node_Assign;

typedef struct AST_Node_Simple{
	enum Node_Type type; // node type
	
	// continue, break or "main" return
	int statement_type;
}AST_Node_Simple;

typedef struct AST_Node_Incr{
	enum Node_Type type; // node type
	
	// identifier
	//list_t *entry;
	
	// increment or decrement
	int incr_type; // 0: increment, 1: decrement
	
	// post- or prefix
	int pf_type; // 0: postfix, 1: prefix
}AST_Node_Incr;

typedef struct AST_Node_Func_Call{
	enum Node_Type type; // node type
	
	// function identifier
	//list_t *entry;
	
	// call parameters
	AST_Node **params;	
}AST_Node_Func_Call;

/* Expressions */
typedef struct AST_Node_Arithm{
	enum Node_Type type; // node type
	
	// operator
	enum Arithm_op op;
	
	struct AST_Node *left;  // left child
	struct AST_Node *right; // right child
}AST_Node_Arithm;

typedef struct AST_Node_Bool{
	enum Node_Type type; // node type
	
	// operator
	enum Bool_op op;
	
	struct AST_Node *left;  // left child
	struct AST_Node *right; // right child
}AST_Node_Bool;

typedef struct AST_Node_Rel{
	enum Node_Type type; // node type
	
	// operator
	enum Rel_op op;
	
	struct AST_Node *left;  // left child
	struct AST_Node *right; // right child
}AST_Node_Rel;

typedef struct AST_Node_Ref{
	enum Node_Type type; // node type
	
	// symbol table entry
	struct hashnode_s *entry;
	
	// reference or not1
	int ref; // 0: not reference, 1: reference
}AST_Node_Ref;

/*
typedef struct AST_Node_Equ{
	enum Node_Type type; // node type
	
	// operator
	enum Equ_op op;
	
	struct AST_Node *left;  // left child
	struct AST_Node *right; // right child
}AST_Node_Equ;
*/
/* Functions */
typedef struct AST_Node_Func_Decl{
	enum Node_Type type; // node type
	
	// return type
	int ret_type;
	
	// symbol table entry
	//list_t *entry;
}AST_Node_Func_Decl;

typedef struct AST_Node_Return{
	enum Node_Type type; // node type
	
	// return type
	int ret_type;
	
	// return value
	struct AST_Node *ret_val;
}AST_Node_Return;

typedef struct AST_Node_Label{
	enum Node_Type type; // node type
	
	// label value;
	int label;
}AST_Node_Label;

typedef struct AST_Node_Labeled_Stm{
	enum Node_Type type; // node type
	
	struct AST_Node *label;
	struct AST_Node *stm;
}AST_Node_Labeled_Stm;

typedef struct AST_Node_Arithm_If{
	enum Node_Type type; // node type
	
	struct AST_Node *expr;
	struct AST_Node *label1;
	struct AST_Node *label2;
	struct AST_Node *label3;
}AST_Node_Arithm_If;

typedef struct AST_Node_Goto{
	enum Node_Type type; // node type

	struct AST_Node *label;
}AST_Node_Goto;

typedef struct AST_Node_Goto_Calc{
	enum Node_Type type; // node type

	struct AST_Node *label;
}AST_Node_Goto_Calc;

typedef struct AST_Node_Branch{
	enum Node_Type type; // node type

	struct AST_Node *expr;
	struct AST_Node *body;
	struct AST_Node *tail;
}AST_Node_Branch;

typedef struct AST_Node_Body{
	enum Node_Type type; // node type

	struct AST_Node *decl;
	struct AST_Node *expr;
}AST_Node_Body;

typedef struct AST_Node_Stms{
	enum Node_Type type; // node type
	
	struct AST_Node *left;
	struct AST_Node *right;
}AST_Node_Stms;

/* ------------------AST NODE MANAGEMENT-------------------- */
/* The basic node */
AST_Node *new_ast_node(Node_Type type, AST_Node *left, AST_Node *right); 	 // simple nodes
/* Declarations */
AST_Node *new_ast_decl_node(DataType data_type, Node *names);					 // declaration
AST_Node *new_ast_const_node(int const_type, Value val);					 // constant
AST_Node *new_ast_decl_list_node(AST_Node *left, AST_Node *right);

/* Statements */
AST_Node *new_ast_assign_node(AST_Node *left, AST_Node *right);
AST_Node *new_ast_if_node(AST_Node *left, AST_Node *right);
/* Expressions */
AST_Node *new_ast_arithm_node(enum Arithm_op op, AST_Node *left, AST_Node *right);
AST_Node *new_ast_bool_node(enum Bool_op op, AST_Node *left, AST_Node *right);
AST_Node *new_ast_rel_node(enum Rel_op op, AST_Node *left, AST_Node *right);

//AST_Node *new_ast_equ_node(enum Equ_op op, AST_Node *left, AST_Node *right);
AST_Node *new_ast_ref_node(struct hashnode_s *entry);

/* Label */
AST_Node *new_ast_label_node(int label);
AST_Node *new_ast_labeled_stm_node(AST_Node *label, AST_Node *stm);
AST_Node *new_ast_arithm_if_node(AST_Node *EXPR, AST_Node *label1, AST_Node *label2, AST_Node *label3);
/* ... */
AST_Node *new_ast_goto_node(AST_Node *label);
AST_Node *new_ast_branch_node(AST_Node *expr, AST_Node *body, AST_Node *tail);
AST_Node *new_ast_body_node(AST_Node *decl, AST_Node *expr);
/**/
void ast_traversal(AST_Node *node);
AST_Node *new_ast_stms_node(AST_Node *left, AST_Node *right);

#endif