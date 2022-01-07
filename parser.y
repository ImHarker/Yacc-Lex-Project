%{
void yyerror (char *s);
int yylex();
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
char aux[100];
int nClasses;
%}

%union {float fnum; int num; char *str;}         /* Yacc definitions */
%start file 

%token <str> RBLeft RBRight BLeft BRight Semicolon Slash Hyphen CBLeft CBRight Comma Dot DDot String  
%token <num> Int
%token <fnum> Float
%type <str> list medicamento
%type symposium classes fabricantes marcasequi

%%

/* descriptions of expected inputs     corresponding actions (in C) */

file: symposium RBLeft classes RBRight RBLeft list RBRight;

symposium: String DDot Int;

classes: String 					{nClasses++;}
	   | classes Comma String		{nClasses++;};

list: medicamento {printf("%s\n",$$);}
	| list medicamento {printf("%s\n", $2);};


medicamento	: BLeft String Comma Int Comma String Comma String Comma Float Comma CBLeft fabricantes CBRight Comma CBLeft marcasequi CBRight BRight Semicolon {strcat($$, " "); strcat($$, $2); strcat($$, " "); strcat($$, $3);};

fabricantes: String
		   | fabricantes Comma String;

marcasequi: String Hyphen String
		  | marcasequi Comma String Hyphen String;

%%                     /* C code */

int main (void) {
	/* init symbol table */
	int out;				
	//extern int yydebug;
   	//yydebug = 1;
	typedef struct medi{
		char nome[25], cat[25], comp[20], fabr[50], equ[50];
		int cod;
		float preco;
	} medicamento;

	if(out = yyparse( )){
		return out;
	}else {
		medicamento *array = malloc(nClasses * sizeof(medicamento)); 
	
		printf("%d\n", nClasses);

		
		free(array);
	}
}

void yyerror (char *s) {fprintf (stderr, "%s\n", s);} 


