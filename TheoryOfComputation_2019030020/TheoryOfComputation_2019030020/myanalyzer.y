%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "cgen.h"

extern int yylex(void);
extern int line_num;
extern int atoi (const char *a);
int var_value;
char* deff;
char* ctor_vars;
char* str_names;
char* comp_name;
int comp_flag;
int num_comps = 0;


%}
%union
{
char* str;
}

%token <str> TOKEN_IDENTIFIER
%token <str> TOKEN_INTEGER
%token <str> TOKEN_REAL
%token <str> TOKEN_STRING

//KEYWORD DEFINITION
%token KW_VOID
%token KW_INTEGER
%token KW_SCALAR
%token KW_STR
%token KW_BOOLEAN
%token KW_TRUE
%token KW_FALSE
%token KW_CONST
%token KW_IF
%token KW_ELSE
%token KW_ENDIF
%token KW_FOR
%token KW_IN
%token KW_ENDFOR
%token KW_WHILE
%token KW_ENDWHILE
%token KW_BREAK
%token KW_CONTINUE
%token KW_NOT
%token KW_AND
%token KW_OR
%token KW_DEF
%token KW_ENDDEF
%token KW_MAIN
%token KW_RETURN
%token KW_COMP
%token KW_ENDCOMP
%token KW_OF

%token OP_EQUAL
%token OP_NOT_EQUAL
%token OP_LESSEQ
%token OP_GREATEREQ
%token OP_INCREQ
%token OP_DECREQ
%token OP_MULCREQ
%token OP_DIVCREQ
%token OP_MODCREQ
%token OP_ASSIGN
%token OP_SQUARE
%token OP_ARROWSIGN
%token OP_COLON_ASSIGN

%right OP_ASSIGN OP_INCREQ OP_DECREQ OP_MULCREQ OP_DIVCREQ OP_MODCREQ OP_COLON_ASSIGN OP_ARROWSIGN
%left KW_OR
%left KW_AND
%right KW_NOT
%left '<' '>' OP_LESSEQ OP_GREATEREQ
%left '*' '/' '%'
%right '+' '-'
%right OP_SQUARE
%left '.' '(' ')' '[' ']'

//main
%type <str> main
%type <str> main_body
%type <str> declarations
%type <str> decl_body

%type <str> types
%type <str> data_type
%type <str> array_value
%type <str> boolean_value
%type <str> expr_data_type


%type <str> assign
%type <str> assign_operator
%type <str> statement

%type <str> expr
%type <str> log_expression
%type <str> ar_expression


%type <str> decl_multiple_var
%type <str> variable_id
%type <str> decl_single_var

%type <str> const_variable_declaration
%type <str> multiple_const_variable_declaration

%type <str> decl_func
%type <str> func_body
%type <str> cmd_stmts
%type <str> return_tp
%type <str> var_args
%type <str> func_args
%type <str> call_function
%type <str> call_function_no
%type <str> call_function_arguments
%type <str> if_statement
%type <str> while_statement
%type <str> for_statement
%type <str> break_statement continue_statement return_statement

%type <str> program


%start program
%%

program:
	main_body
	{
	 $$ = template("%s",$1);
	 if (yyerror_count == 0)
	 {    
	FILE *fp = fopen("C_file.c","w");

	printf("\n\t\t\tC CODE\n");
	printf("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ \n");
	printf("\n%s\n", $1);
	printf("\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ \n");
	printf("\t\t\tC CODE END\n");
	fputs("#include <stdio.h>\n",fp);
	fputs("#include <math.h>\n",fp);
	fputs(c_prologue,fp);// include kappalib.h
	fprintf(fp,"%s\n", $1);

	fclose(fp);
	}
};

// ========================================================Main========================================================
	main_body:
		 decl_body main { $$ = template("%s\n%s\n",$1,$2); }
		 | main { $$ = $1; };


	main:
		KW_DEF KW_MAIN '(' ')' ':' func_body KW_ENDDEF ';'{$$ = template("int main(){\n%s\n}", $6);};

// =====================================================Data Types===================================================
	
	data_type:
		 '[' ']' types { $$ = template("%s*", $3); }
	|	  types { $$ = $1; };
	//|	  TOKEN_IDENTIFIER { $$ = template("%s", $1); };
	
	types:
		KW_INTEGER {$$ = template("%s", "int");}
	|	KW_BOOLEAN {$$ = template("%s", "int");}	
	|	KW_SCALAR  {$$ = template("%s","double");}
	|	KW_STR     {$$ = template("%s", "char*");};
	

// ========================================================Declarations========================================================
	decl_body:
	 	 decl_body declarations {$$=template("%s\n%s\n",$1,$2);}
	| 	 declarations 		{$$=template("%s\n",$1);}  
	;

	declarations:
	   	const_variable_declaration                {$$=template("%s",$1);}
	|   	decl_single_var                      	  {$$=template("%s",$1);}
	|   	decl_func               		  {$$=template("%s",$1);}
	;


	
// ========================================================Expressions========================================================



	expr:
		log_expression {$$=template("%s",$1);}
		;

	
	boolean_value:
	 	KW_TRUE 		{ $$ = "1"; }
	|	KW_FALSE 		{ $$ = "0"; }
	;

	array_value:
		TOKEN_IDENTIFIER '[' expr ']'				{ $$ = template("%s[%s]", $1, $3); }
	| 	TOKEN_IDENTIFIER '[' ']'				{ $$ = template("%s*", $1); }
	;

	expr_data_type:
	 	TOKEN_INTEGER				{ $$ = template("%s", $1); }
	| 	TOKEN_REAL 				{ $$ = template("%s", $1); }
	| 	TOKEN_STRING 				{ $$ = template("%s",$1);}
	|	TOKEN_IDENTIFIER			{ $$ = template("%s", $1); }
	| 	array_value				{ $$ = template("%s", $1); }
	|	boolean_value 				{ $$ = template("%s", $1); }
	|	call_function_no			{ $$ = template("%s",$1);}
	|	'(' expr ')'				{ $$ = template("%s", $2); }
	;
	

	ar_expression:
		expr_data_type {$$=template("%s",$1);}
	| 	ar_expression OP_SQUARE expr_data_type {$$=template("pow((double)%s,(double)%s)", $1, $3); }
	| 	ar_expression '/' expr_data_type {$$=template("%s / %s", $1, $3); }
	|	ar_expression '*' expr_data_type {$$=template("%s * %s", $1, $3); }
	|	ar_expression '%' expr_data_type {$$=template("((int)%s) % ((int)%s)", $1, $3); }
	|	ar_expression '+' expr_data_type {$$=template("%s + %s", $1, $3); }
	|	ar_expression '-' expr_data_type {$$=template("%s - %s", $1, $3); }
	|	'+' ar_expression 	  	 {$$=template("+%s",$2);}
	|	'-' ar_expression 		 {$$=template("-%s",$2);}
	;

	log_expression: 
		ar_expression 				  {$$=template("%s",$1);}
	| 	log_expression OP_LESSEQ ar_expression    {$$=template("%s <= %s",$1,$3);}
	|	log_expression OP_GREATEREQ ar_expression {$$=template("%s >= %s",$1,$3);}
	| 	log_expression '<' ar_expression {$$=template("%s < %s",$1,$3);}
	| 	log_expression '>' ar_expression {$$=template("%s > %s",$1,$3);}
	| 	log_expression OP_EQUAL ar_expression     {$$=template("%s == %s",$1,$3);}
	| 	log_expression OP_NOT_EQUAL ar_expression {$$=template("%s != %s",$1,$3);}
	| 	KW_NOT ar_expression 			  {$$=template("!%s",$2);}
	| 	log_expression KW_AND ar_expression {$$=template("%s && %s",$1,$3);}
	| 	log_expression KW_OR ar_expression  {$$=template("%s || %s",$1,$3);}

	;
	//=================================Variables declaration==========================================================
	
	variable_id:
		TOKEN_IDENTIFIER '[' expr ']' OP_ASSIGN expr   {$$=template("%s[%s]=%s", $1,$3,$6);}
	| 	TOKEN_IDENTIFIER '['']' OP_ASSIGN expr         {$$=template("%s*[]=%s", $1,$5);}
	| 	TOKEN_IDENTIFIER OP_ASSIGN expr                {$$=template("%s = %s", $1,$3);}
	| 	array_value			               {$$ = template("%s", $1); }
	| 	TOKEN_IDENTIFIER                               {$$=template("%s", $1);}
	;


	decl_single_var:
		decl_multiple_var ':' data_type';' {$$=template("%s %s;\n", $3,$1);}
	;

	decl_multiple_var:
		decl_multiple_var ',' variable_id
	| 	variable_id
	;

	

	//=================================Const declaration==========================================================
	
	
	const_variable_declaration:
		KW_CONST multiple_const_variable_declaration ':' data_type ';' {$$=template("const %s %s;\n", $4,$2);}
	;

	multiple_const_variable_declaration:
		multiple_const_variable_declaration ',' variable_id {$$=template("%s, %s", $1,$3);}
	| 	variable_id {$$=$1;}
	;

	//=================================Functions declaration==========================================================
	


	decl_func:
		KW_DEF TOKEN_IDENTIFIER '(' func_args ')' OP_ARROWSIGN return_tp ':' func_body KW_ENDDEF ';' {$$=template("%s %s(%s) {\n%s\n}",$7,$2,$4,$9);}
	;

	return_tp:
		KW_VOID              {$$=template("void");}
	|	KW_INTEGER           {$$=template("int");}
	|	KW_SCALAR            {$$=template("double");}
	|	KW_STR               {$$=template("StringType");}
	|	KW_BOOLEAN           {$$=template("int");} //returns 0 or 1
	|	TOKEN_IDENTIFIER     {$$=template("%s", $1);}
	;
	
	var_args:
		 TOKEN_IDENTIFIER '['TOKEN_INTEGER']' ':' data_type 	{$$=template("%s %s[%s]", $6,$1,$3);}
	|	 TOKEN_IDENTIFIER '[' ']' ':' data_type 		{$$=template("%s *%s", $5,$1);}
	|	 TOKEN_IDENTIFIER ':' data_type 			{$$=template("%s %s", $3,$1);}
	|	 TOKEN_IDENTIFIER '['TOKEN_INTEGER']' ':' TOKEN_IDENTIFIER 	{$$=template("%s %s[%s]", $6,$1,$3);}
	|	 TOKEN_IDENTIFIER '[' ']' ':' TOKEN_IDENTIFIER 		{$$=template("%s *%s", $5,$1);}
	|	 TOKEN_IDENTIFIER ':' TOKEN_IDENTIFIER 			{$$=template("%s %s", $3,$1);}
	;


	func_args:
		var_args ',' func_args {$$=template("%s, %s", $1,$3);}
	| 	var_args {$$=template("%s", $1);}
	|	%empty {$$=template("");}
	;

	func_body:
	%empty {$$=template(" ");}
	| cmd_stmts {$$=template("%s",$1);}
	;
	
	call_function :
		TOKEN_IDENTIFIER '(' call_function_arguments ')' ';' {$$ = template("%s(%s);",$1,$3);}
	| 	TOKEN_IDENTIFIER '('')' ';' {$$ = template("%s();",$1);}
	;

	call_function_no:
		TOKEN_IDENTIFIER '(' call_function_arguments ')' {$$ = template("%s(%s)",$1,$3);}
	| 	TOKEN_IDENTIFIER '('')' {$$ = template("%s()",$1);}
	;

	call_function_arguments :
	call_function_arguments ',' expr {$$ = template("%s, %s",$1,$3);}
	| expr {$$ = $1;}
	;


	//=================================Statements===========================================================

	statement:
	 	assign {$$=template("%s\n",$1);}
	| 	decl_single_var {$$=template("%s",$1);}
	| 	const_variable_declaration {$$=template("%s",$1);}
	| 	if_statement {$$=template("%s",$1);}
	| 	for_statement {$$=template("%s",$1);}
	| 	while_statement {$$=template("%s",$1);}
	| 	break_statement ';' { $$ = $1; }
	| 	continue_statement ';' { $$ = $1; }
	| 	return_statement ';'   { $$ = $1; }
	|	KW_RETURN expr ';'     { $$ = template("return %s;", $2); }
	| 	call_function {$$=template("%s",$1);}
	;
	
	assign_operator:
		OP_INCREQ {$$=template("+=");}
	| 	OP_DECREQ {$$=template("-=");}
	| 	OP_MULCREQ {$$=template("*=");}
	| 	OP_DIVCREQ {$$=template("/=");}
	| 	OP_MODCREQ {$$=template("%=");}
	;
	
	assign:
		TOKEN_IDENTIFIER OP_ASSIGN expr ';'			{$$=template("%s = %s;", $1,$3);}
	|	TOKEN_IDENTIFIER assign_operator expr ';'			{$$=template("%s %s %s;", $1,$2,$3);}
	|	TOKEN_IDENTIFIER '[' expr ']' OP_ASSIGN expr ';'	{$$=template("%s[%s] = %s;", $1,$3,$6); }	
	|	TOKEN_IDENTIFIER '[' expr ']' assign_operator expr ';'	{$$=template("%s[%s] %s %s;", $1,$3,$5,$6); }	
	|	TOKEN_IDENTIFIER '['']' OP_ASSIGN expr ';'		{$$=template("%s[] = %s;", $1,$5); }
	|	TOKEN_IDENTIFIER '['']' assign_operator expr ';'		{$$=template("%s[] %s %s;", $1,$4,$5); }
	|	TOKEN_IDENTIFIER OP_COLON_ASSIGN '[' expr KW_FOR TOKEN_IDENTIFIER ':' expr ']' ':' data_type ';'
	{
		$$=template("%s* %s=(%s*)malloc(%s*sizeof(%s));\n"
		"for(int %s=0; %s<%s; ++%s){\n"
		"%s[%s]=%s;}",$11, $1, $11, $8, $11, $6, $6, $8, $6, $1, $6, $6);
	}
	|	TOKEN_IDENTIFIER OP_COLON_ASSIGN '[' expr KW_FOR TOKEN_IDENTIFIER ':' data_type KW_IN TOKEN_IDENTIFIER KW_OF expr ']' ':' data_type ';'
		{ 
		char str[strlen($4)+1], substr[strlen($6)+1], replace[2*strlen($10)+5];
		char* output = malloc(70);
		
		sprintf(str, "%s", $4);
		sprintf(substr, "%s", $6);
		sprintf(replace,"%s[%s_i]", $10,$10);
		char* token = strtok(str,substr);

		sprintf(output,"%s",""); //initialise so we can compare
		
		while(token!=NULL){
			sprintf(output,"%s%s%s", output,replace,token);
			token = strtok(NULL,substr);
		}

		$$ = template("%s* %s = (%s*)malloc(%s* sizeof(%s));\nfor (int %s_i=0; %s_i < %s; ++%s_i){\n%s[%s_i] = %s;\n}", $15, $1, $15, $12, $15, $10, $10, $12, $10, $1, $10, output);
		}
	;

	
		

	cmd_stmts:
		cmd_stmts statement   {$$ = template("%s\n%s", $1,$2);}
	| 	statement {$$ = template("%s",$1);}
	;
	
	if_statement:
	  	KW_IF '(' expr ')' ':' cmd_stmts KW_ENDIF ';' {$$ = template("if (%s) {\n%s\n}", $3, $6);}
	  	| KW_IF '(' expr ')' ':' cmd_stmts KW_ELSE ':' cmd_stmts KW_ENDIF ';'{$$ = 	template("if (%s) {\n%s\n} else {\n%s\n}", $3, $6, $9);};


	for_statement:
		  KW_FOR TOKEN_IDENTIFIER KW_IN '[' expr ':' expr ']' ':'cmd_stmts KW_ENDFOR ';' {$$ = template("for (int %s = %s; %s < %s; %s++) {\n%s\n}", $2, $5, $2, $7, $2, $10);}
		  | KW_FOR TOKEN_IDENTIFIER KW_IN '[' expr ':' expr ':' expr ']' ':' cmd_stmts KW_ENDFOR ';' {$$ = template("for (int %s = %s; %s < %s; %s = %s + %s) {\n%s\n}", $2, $5, $2, $7, 	$2, $2, $9, $12);};

	while_statement:
		KW_WHILE '(' expr ')' ':' cmd_stmts KW_ENDWHILE ';'       {$$ = template("while(%s){\n%s}\n",$3,$6);}
		;
	
	
	break_statement:
		KW_BREAK ';' 				{ $$ = "break; "; }
		;
	
	continue_statement:
		KW_CONTINUE ';'				{ $$ = "continue; "; }
		;
		
	return_statement:
		KW_RETURN ';'				{ $$ = "return;"; }
		
		;
	
	%%
	int main() {
	if ( yyparse() == 0 )
	printf("Your program is syntactically correct!\n");
	else
	printf("Error!\n");
	}
