%{
#include <string>
#include "node.h"
#include "parser.hpp"

#define SAVE_TOKEN  yylval.string = new std::string(yytext, yyleng)
#define TOKEN(t)    (yylval.token = t)
%}

%option noyywrap

%%

[ \t\n]                 ;

"return"              return TOKEN(TRETURN);
"__device__"           SAVE_TOKEN; return TDEVICE;
"char4"                SAVE_TOKEN; return TCHAR4;
".xyzw"                 return TOKEN(TXYZW);
".wzyx"                 return TOKEN(TWZYX);

[a-zA-Z_][a-zA-Z0-9_]*  SAVE_TOKEN; return TIDENTIFIER;
[0-9]+\.[0-9]* 		SAVE_TOKEN; return TDOUBLE;
[0-9]+			SAVE_TOKEN; return TINTEGER;

"="			return TOKEN(TEQUAL);
"=="				          	return TOKEN(TCEQ);
"!="			          		return TOKEN(TCNE);
"<"				          		return TOKEN(TCLT);
"<="	          				return TOKEN(TCLE);
">"				          		return TOKEN(TCGT);
">="					          return TOKEN(TCGE);

"("	          					return TOKEN(TLPAREN);
")"					          	return TOKEN(TRPAREN);
"{"         						return TOKEN(TLBRACE);
"}"					          	return TOKEN(TRBRACE);

","				          		return TOKEN(TCOMMA);

"+"				          		return TOKEN(TPLUS);
"-"		          				return TOKEN(TMINUS);
"*"		          				return TOKEN(TMUL);
"/"				          		return TOKEN(TDIV);

.                       printf("Unknown token!\n"); yyterminate();

%%
