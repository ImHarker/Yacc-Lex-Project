%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
void arrayAlloc();
void yyerror (char *s);
void newMed();
int yylex();
char aux[100];
int nClasses = 0;
int *nMedsClasse = NULL; 
typedef struct medi{
	char nome[25], cat[25], comp[20], fabr[50], equ[50];
	int cod;
	float preco;
} medicamento;
medicamento tmp;
medicamento **array = NULL;
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

classes: String 					{nClasses++; arrayAlloc();}
	   | classes Comma String		{nClasses++; arrayAlloc();};

list: medicamento 
	| list medicamento ;


medicamento	: BLeft String Comma Int Comma String Comma String Comma Float Comma CBLeft fabricantes CBRight Comma CBLeft marcasequi CBRight BRight Semicolon {strcpy(tmp.nome, $2); tmp.cod = $4; strcpy(tmp.cat, $6); strcpy(tmp.comp, $8); tmp.preco = $10; newMed(); };

fabricantes: String
		   | fabricantes Comma String;

marcasequi: String Hyphen String
		  | marcasequi Comma String Hyphen String;

%%                     /* C code */

int main (void) {
	/* init symbol table */
	int out;
	int i;
	//extern int yydebug;
   	//yydebug = 1;
	if(out = yyparse( )){
		for(i = 0; i< nClasses; i++){
			free(array[i]);
		}
		free(array);
		free(nMedsClasse);
		return out;
	}else {
		printf("%s\n", array[0][0].cat);
		printf("%s\n", array[1][0].cat);
		printf("Nome: %s\tCod: %d\t\tCat: %s\tComp: %s\tPreco:%.2f\n", tmp.nome, tmp.cod, tmp.cat, tmp.comp, tmp.preco);  
		for(i = 0; i< nClasses; i++){
			free(array[i]);
		}
		free(array);
		free(nMedsClasse);
		return out;
	}
}

void arrayAlloc(){
		int i;
		array = (medicamento**)realloc(array, nClasses * sizeof(medicamento*)); 
		nMedsClasse = (int*)realloc(nMedsClasse, nClasses * sizeof(int));
		for(i=0; i<nClasses;i++){
			nMedsClasse[i] = 0;
		}

		if(!array || !nMedsClasse){ printf("Não foi possivel alocar a memoria"); exit(1);}

		printf("%d Classes alocadas!\n", nClasses);

}
void newMed(){
	int i;
	for(i=0; i<nClasses; i++){
		if(nMedsClasse[i] != 0){
			if(strcmp(array[i][0].cat, tmp.cat)== 0){
				++nMedsClasse[i];
				array[i] = (medicamento*)realloc(array[i], nMedsClasse[i] * sizeof(medicamento));
				strcpy(array[i][nMedsClasse[i]-1].cat, tmp.cat);
				//adicionar outros parametros
				break;
			}
		}else { 
			++nMedsClasse[i];
			array[i] = (medicamento*)realloc(array[i], nMedsClasse[i] * sizeof(medicamento));
			strcpy(array[i][0].cat, tmp.cat);
			//adicionar outros parametros
			break;
		}
	}
}
void yyerror (char *s) {fprintf (stderr, "%s\n", s);} 


