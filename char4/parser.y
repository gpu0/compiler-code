%{
	#include "node.h"
  #include <cstdio>
  #include <cstdlib>
	NBlock *programBlock; /* the top level root node of our final AST */

	extern int yylex();
	void yyerror(const char *s) { std::printf("Error: %s\n", s);std::exit(1); }
%}

/* Represents the many different ways we can access our data */
%union {
	Node *node;
	NBlock *block;
	NExpression *expr;
	NStatement *stmt;
	NIdentifier *ident;
	NVariableDeclaration *var_decl;
	std::vector<NVariableDeclaration*> *varvec;
	std::vector<NExpression*> *exprvec;
	std::string *string;
	int token;
}

/* Define our terminal symbols (tokens). This should
   match our tokens.l lex file. We also define the node type
   they represent.
 */
%token <string> TIDENTIFIER TINTEGER TDOUBLE
%token <token> TCEQ TCNE TCLT TCLE TCGT TCGE TEQUAL
%token <token> TLPAREN TRPAREN TLBRACE TRBRACE TCOMMA TDOT
%token <token> TPLUS TMINUS TMUL TDIV
%token <token> TIF TDEVICE TCHAR4
%token <token> TRETURN TXYZW TWZYX

/* Define the type of node our nonterminal symbols represent.
   The types refer to the %union declaration above. Ex: when
   we call an ident (defined by union type ident) we are really
   calling an (NIdentifier*). It makes the compiler happy.
 */
%type <ident> ident
%type <expr> numeric expr
%type <block> program stmts block
%type <varvec> func_decl_args
%type <stmt> stmt var_decl if_block func_decl
%type <token> comparison

/* Operator precedence for mathematical operators */
%left TPLUS TMINUS
%left TMUL TDIV

%start program

%%

program : stmts { programBlock = $1; }
		;

stmts : stmt { $$ = new NBlock(); $$->statements.push_back($<stmt>1); }
	  | stmts stmt { $1->statements.push_back($<stmt>2); }
	  ;

stmt : var_decl |  if_block | func_decl
	 | expr { $$ = new NExpressionStatement(*$1); }
	 | TRETURN ident { $$ = new NReturnStatement(*$2); }
     ;

block : TLBRACE stmts TRBRACE { $$ = $2; }
	  | TLBRACE TRBRACE { $$ = new NBlock(); }
	  ;

var_decl : ident ident { $$ = new NVariableDeclaration(*$1, *$2); }
		| TCHAR4 ident { $$ = new NVariableDeclaration(*new NIdentifier("char4"), *$2); delete $2; }
		 | ident ident TEQUAL expr { $$ = new NVariableDeclaration(*$1, *$2, $4); }
		 ;

func_decl: TDEVICE TCHAR4 ident TLPAREN func_decl_args TRPAREN block
                { $$ = new NFunctionDeclaration(*$3, *$5, *$7); delete $5;  }
               ;

func_decl_args: { $$ = new VariableList(); }
              | var_decl { $$ = new VariableList(); $$->push_back($<var_decl>1); }
              | func_decl_args TCOMMA var_decl { $1->push_back($<var_decl>3); }

if_block : TIF TLPAREN expr TRPAREN  block  { $$ = new NIfBlock($3, *$5); }

ident : TIDENTIFIER { $$ = new NIdentifier(*$1); delete $1; }
			|	TIDENTIFIER TXYZW { $$ = new NIdentifier(*$1, TXYZW); delete $1; }
			|	TIDENTIFIER TWZYX { $$ = new NIdentifier(*$1, TWZYX); delete $1; }
	  ;

numeric : TINTEGER { $$ = new NInteger(atol($1->c_str())); delete $1; }
		| TDOUBLE { $$ = new NDouble(atof($1->c_str())); delete $1; }
		;

expr : ident TEQUAL ident { $$ = new NAssignment(*$<ident>1, *$<ident>3); }
	 | ident { $<ident>$ = $1; }
	 | numeric
         | expr TMUL expr { $$ = new NBinaryOperator(*$1, $2, *$3); }
         | expr TDIV expr { $$ = new NBinaryOperator(*$1, $2, *$3); }
         | expr TPLUS expr { $$ = new NBinaryOperator(*$1, $2, *$3); }
         | expr TMINUS expr { $$ = new NBinaryOperator(*$1, $2, *$3); }
 	 | expr comparison expr { $$ = new NBinaryOperator(*$1, $2, *$3); }
     | TLPAREN expr TRPAREN { $$ = $2; }
	 ;



comparison : TCEQ | TCNE | TCLT | TCLE | TCGT | TCGE;

%%
