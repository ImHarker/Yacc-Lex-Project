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
%type <str> list medicamento fabricantes marcasequi
%type symposium classes

%%

/* descriptions of expected inputs     corresponding actions (in C) */

file: symposium RBLeft classes RBRight RBLeft list RBRight;

symposium: String DDot Int;

classes: String 					{nClasses++; arrayAlloc();}
	   | classes Comma String		{nClasses++; arrayAlloc();};

list: medicamento 
	| list medicamento ;


medicamento	: BLeft String Comma Int Comma String Comma String Comma Float Comma CBLeft fabricantes CBRight Comma CBLeft marcasequi CBRight BRight Semicolon {strcpy(tmp.nome, $2); tmp.cod = $4; strcpy(tmp.cat, $6); strcpy(tmp.comp, $8); tmp.preco = $10; strcpy(tmp.fabr, $13); strcpy(tmp.equ, $17); newMed(); };

fabricantes: String 
		   | fabricantes Comma String {strcat($$, $2); strcat($$,$3);};

marcasequi: String Hyphen String	{strcat($$,$2); strcat($$,$3);}
		  | marcasequi Comma String Hyphen String {strcat($$,$2); strcat($$,$3); strcat($$,$4); strcat($$, $5);};

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
		printf("Nome: %s\tCod: %d\t\tCat: %s\tComp: %s\tPreco:%.2f\tFabr: %s\tEqui:%s\n", array[0][0].nome, array[0][0].cod, array[0][0].cat, array[0][0].comp, array[0][0].preco, array[0][0].fabr, array[0][0].equ);  
	printf("Nome: %s\tCod: %d\t\tCat: %s\tComp: %s\tPreco:%.2f\tFabr: %s\tEqui:%s\n", array[1][0].nome, array[1][0].cod, array[1][0].cat, array[1][0].comp, array[1][0].preco, array[1][0].fabr, array[1][0].equ);  
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
				strcpy(array[i][nMedsClasse[i]-1].nome, tmp.nome);
				strcpy(array[i][nMedsClasse[i]-1].comp, tmp.comp);
				strcpy(array[i][nMedsClasse[i]-1].fabr, tmp.fabr);
				strcpy(array[i][nMedsClasse[i]-1].equ, tmp.equ);
				array[i][nMedsClasse[i]-1].cod = tmp.cod;
				array[i][nMedsClasse[i]-1].preco = tmp.preco;

				break;
			}
		}else { 
			++nMedsClasse[i];
			array[i] = (medicamento*)realloc(array[i], nMedsClasse[i] * sizeof(medicamento));
				strcpy(array[i][0].cat, tmp.cat);
				strcpy(array[i][0].nome, tmp.nome);
				strcpy(array[i][0].comp, tmp.comp);
				strcpy(array[i][0].fabr, tmp.fabr);
				strcpy(array[i][0].equ, tmp.equ);
				array[i][0].cod = tmp.cod;
				array[i][0].preco = tmp.preco;
			break;
		}
	}
}
void yyerror (char *s) {fprintf (stderr, "%s\n", s);} 


