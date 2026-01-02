%{
		#include <stdio.h>
		#include <string.h>
		#include "myanalyzer.tab.h"
		#include "cgen.h"
		
		// Everything that was firstly defined in this prologue at the lexer implementation, is now being transfered to the analyser as a %token.
		
    int line_num = 1;
		
%}



/* Identifiers */ 
IDENTIFIER     [a-zA-Z][0-9a-zA-Z_]*

/* Types of difits */ 
NON_ZERO_DIGIT   [1-9]
DIGIT            [0-9]

/* Integers */ 
INTEGER         0|{NON_ZERO_DIGIT}{DIGIT}*

/* Floating point */
DECIMAL 	("."{INTEGER})|({INTEGER}("."{INTEGER}?)?)
REAL            {DECIMAL}([eE][+-]?{INTEGER})?

/* String */

/*[^\"'\\] Matches evry character exept for "'\\*/
COMMON_CHAR     [., a-zA-Z0-9\-+\*\/:_$!#@&~^()]  
ESCAPE_CHAR     [\\n]|[\\t]|[\\r]|[\\\\]|[\\\"]
STRING          (\"(({ESCAPE_CHAR})|({COMMON_CHAR}))*\")


%%

 /*  KEYWORDS  */

"integer"    {printf("Found token INTEGER: %s\n",yytext);return KW_INTEGER;}
"scalar"     {printf("Found token SCALAR: %s\n",yytext);return KW_SCALAR;}
"str"        {printf("Found token STR: %s\n",yytext);return KW_STR;}
"boolean"    {printf("Found token BOOLEAN: %s\n",yytext);return KW_BOOLEAN;}
"True"       {printf("Found token TRUE: %s\n",yytext);return KW_TRUE;}
"False"      {printf("Found token FALSE: %s\n",yytext);return KW_FALSE;}
"const"      {printf("Found token CONST: %s\n",yytext);return KW_CONST;}
"if"         {printf("Found token IF: %s\n",yytext);return KW_IF;}
"else"       {printf("Found token ELSE: %s\n",yytext);return KW_ELSE;}
"endif"      {printf("Found token ENDIF: %s\n",yytext); return KW_ENDIF; }
"for"        {printf("Found token FOR: %s\n",yytext); return KW_FOR; }
"in"         {printf("Found token IN: %s\n",yytext); return KW_IN; }
"endfor"     {printf("Found token ENDFOR: %s\n",yytext); return KW_ENDFOR; }
"while"      {printf("Found token WHILE: %s\n",yytext); return KW_WHILE; }
"endwhile"   {printf("Found token ENDWHILE: %s\n",yytext); return KW_ENDWHILE; }
"break"      {printf("Found token BREAK: %s\n",yytext); return KW_BREAK; }
"continue"   {printf("Found token CONTINUE: %s\n",yytext); return KW_CONTINUE; }
"not"        {printf("Found token NOT: %s\n",yytext); return KW_NOT; }
"and"        {printf("Found token AND: %s\n",yytext); return KW_AND; }
"or"         {printf("Found token OR: %s\n",yytext); return KW_OR; }
"def"        {printf("Found token DEF: %s\n",yytext); return KW_DEF; }
"enddef"     {printf("Found token ENDDEF: %s\n",yytext); return KW_ENDDEF; }
"main"       {printf("Found token MAIN: %s\n",yytext); return KW_MAIN; }
"return"     {printf("Found token RETURN: %s\n",yytext); return KW_RETURN; }
"comp"        {printf("Found token COMP: %s\n",yytext); return KW_COMP; }
"endcomp"    {printf("Found token ENDCOMP: %s\n",yytext); return KW_ENDCOMP; }
"of"         {printf("Found token OF: %s\n",yytext); return KW_OF; }

 /*  OPERATORS  */
"+"          {printf("Found token PLUS: %s\n",yytext); return '+';} 
"-"          {printf("Found token MINUS: %s\n",yytext); return '-';}
"*"          {printf("Found token MULT: %s\n",yytext); return '*';}
"/"          {printf("Found token DIV: %s\n",yytext); return '/';}
"%"          {printf("Found token MOD: %s\n",yytext); return '%';}

"**"         {printf("Found token SQUARE: %s\n",yytext); return OP_SQUARE;} 
"=="         {printf("Found token EQUAL: %s\n",yytext); return OP_EQUAL;}
"!="         {printf("Found token NOTEQ: %s\n",yytext); return OP_NOT_EQUAL;}
"<"          {printf("Found token LESS: %s\n",yytext); return '<';}
"<="         {printf("Found token LESSEQ: %s\n",yytext); return OP_LESSEQ;}
">"          {printf("Found token GREATER: %s\n",yytext); return '>';}
">="         {printf("Found token GREATEREQ: %s\n",yytext); return OP_GREATEREQ;}
"="          {printf("Found token ASSIGN: %s\n",yytext); return OP_ASSIGN;}
"+="         {printf("Found token INCREQ: %s\n",yytext); return OP_INCREQ;}
"-="         {printf("Found token DECREQ: %s\n",yytext); return OP_DECREQ;}
"*="         {printf("Found token MULCREQ: %s\n",yytext); return OP_MULCREQ;}
"/="         {printf("Found token DIVCREQ: %s\n",yytext); return OP_DIVCREQ;}
"%="         {printf("Found token MODCREQ: %s\n",yytext); return OP_MODCREQ;}
":="         {printf("Found token COLON_ASSIGN: %s\n",yytext); return OP_COLON_ASSIGN;}
"->"	     {printf("Found token ARROWSIGN: %s\n",yytext); return OP_ARROWSIGN;}

 /*  DELIMETERS  */
";"          {printf("Found token QUESTIONMARK: %s\n",yytext); return ';';}
"("          {printf("Found token LEFT PARENTHESIS: %s\n",yytext); return '(';}
")"          {printf("Found token RIGHT PARENTHESIS: %s\n",yytext); return ')';}
","          {printf("Found token COMMA: %s\n",yytext); return ',';}
"["          {printf("Found token LEFT BRACET: %s\n",yytext); return '[';}
"]"          {printf("Found token RIGHT BRACET: %s\n",yytext); return ']';}
":"          {printf("Found token DOTS: %s\n",yytext);  return ':';}
"."          {printf("Found token DOT: %s\n",yytext); return '.';}


{IDENTIFIER}			{ yylval.str = strdup(yytext);printf("Found keyward IDENTIFIER: %s\n", yytext); return TOKEN_IDENTIFIER;}
{INTEGER}			{ yylval.str = strdup(yytext);printf("Found keyward INTEGER: %s\n", yytext); return TOKEN_INTEGER;}
{REAL}				{ yylval.str = strdup(yytext);printf("Found keyward REAL: %s\n", yytext); return TOKEN_REAL;}
{STRING}			{ yylval.str = strdup(yytext);printf("Found keyward STRING: %s\n", yytext); return TOKEN_STRING;}


"--"[^\n]*  printf("//Line %d: line comment: %s\n", line_num, yytext);/* eat line comments */

[ \r\t]+		/* eat whitespace */
\n 					 ++line_num;

<<EOF>> 	return EOF;
.           { printf("Line %d Lexical Error: Unrecognized literal %s\n", line_num, yytext); }
%%


