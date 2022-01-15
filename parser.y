%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
void arrayAlloc();
void yyerror (char *s);
void newMed();
void printMeds();
void cleanup();
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


%union {float fnum; int num; char *str;}         
%start file 

%token <str> RBLeft RBRight BLeft BRight Semicolon Slash Hyphen CBLeft CBRight Comma Dot DDot String  
%token <num> Int
%token <fnum> Float
%type <str> list medicamento fabricantes marcasequi
%type symposium classes

%%

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

%%
int main (void) {
	int out;
	//extern int yydebug; //debug
   	//yydebug = 1;			//debug
	if(out = yyparse( )){	//ERROR
		cleanup();
		return out;
	}else {					//Success
		printMeds();
		cleanup();	
		return out;
	}
}

void arrayAlloc(){	//Used to allocate the base matrix of pointers to 'medicamento'
		int i;
		array = (medicamento**)realloc(array, nClasses * sizeof(medicamento*)); //allocate base matrix
		nMedsClasse = (int*)realloc(nMedsClasse, nClasses * sizeof(int)); 		//allocate number of 'medicamentos'/type
		for(i=0; i<nClasses;i++){	//initialize value 
			nMedsClasse[i] = 0;
		}

		if(!array || !nMedsClasse){ printf("Não foi possivel alocar a memoria"); exit(1);}	//Error: Allocation failed. return 1

}
void newMed(){	//Used to create a new 'medicamento' in the matrix according to the type
	int i;
	for(i=0; i<nClasses; i++){
		if(nMedsClasse[i] != 0){	//Already is a 'medicamento' in this type
			if(strcmp(array[i][0].cat, tmp.cat)== 0){ //Checks the type
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
		}else { //First 'medicamento' of this type
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
void printMeds(){	//Used to print all the 'medicamento's in the matrix
	int i,j;
	for( i = 0; i < nClasses; i++){
		for( j=0; j < nMedsClasse[i]; j++){
			printf("Nome: %s\nCod: %d\nCat: %s\nComp: %s\nPreco: %.2f\nFabr: %s\nEqui: %s\n-----------------------\n", array[i][j].nome, array[i][j].cod, array[i][j].cat, array[i][j].comp, array[i][j].preco, array[i][j].fabr, array[i][j].equ);  
		} 
	}




} 
void cleanup(){ //Used to free the memory allocated
	int i;
	for(i = 0; i< nClasses; i++){
		free(array[i]);
	}
	free(array);
	free(nMedsClasse);
	
}
void yyerror (char *s) {fprintf (stderr, "%s\n", s);} 


