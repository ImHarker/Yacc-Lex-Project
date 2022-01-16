%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
extern int yylineno;
void sort();
void arrayAlloc();
void yyerror (char *s);
void newMed();
void printMeds();
void cleanup();
void HTMLgen();
int yylex();
char aux[100];
int ano;
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

symposium: String DDot Int          {ano = $3;};

classes: String 					{nClasses++; arrayAlloc();}
	   | classes Comma String		{nClasses++; arrayAlloc();};

list: medicamento 
	| list medicamento;


medicamento	: BLeft String Comma Int Comma String Comma String Comma Float Comma CBLeft fabricantes CBRight Comma CBLeft marcasequi CBRight BRight Semicolon {strcpy(tmp.nome, $2); tmp.cod = $4; strcpy(tmp.cat, $6); strcpy(tmp.comp, $8); tmp.preco = $10; strcpy(tmp.fabr, $13); strcpy(tmp.equ, $17); newMed(); };

fabricantes: String 
		   | fabricantes Comma String {strcat($$, $2); strcat($$," "); strcat($$,$3);};

marcasequi: String Hyphen String	{strcat($$,$2); strcat($$,$3);}
		  | marcasequi Comma String Hyphen String {strcat($$,$2); strcat($$, " "); strcat($$,$3); strcat($$,$4); strcat($$, $5);};

%%
int main (void) {
	int out;
	//extern int yydebug; //debug
   	//yydebug = 1;			//debug
	if(out = yyparse( )){	//ERROR
		cleanup();
		return out;
	}else {					//Success
		sort();
		printMeds();
		HTMLgen();
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
void sort(){
int i, j,k;
	for(i =0; i< nClasses; i++){
		for(j=0;j<nMedsClasse[i]; j++){
			for(k=0;k<nMedsClasse[i]-j-1; k++){
				if(strcmp(array[i][j].nome, array[i][j+1].nome) > 0){
					tmp = array[i][j];
					array[i][j] = array[i][j+1];
					array[i][j+1] = tmp;
				}
			}
		}
	}

}
void HTMLgen(){
	FILE *fptr;
	int i, j;
  	char filepath[50] = "./www/";

	system("mkdir ./www 2>/dev/null");
	system("rm ./www/*.html 2>/dev/null");
	
	strcat(filepath, "index");
	strcat(filepath, ".html");
	fptr = fopen(filepath, "w");
	if(!fptr){
		fprintf(stderr, "Impossivel abrir o ficheiro %s", filepath);
		return;
	}
	fprintf(fptr, "<html>\n\t<head>\n\t\t<title>Symposium %d</title>\n\t</head>\n", ano);
	fprintf(fptr, "\t<body>\n\t\t<h1>Classes de Medicamentos Disponiveis</h1>\n\t\t<ul>");
	for(i=0; i< nClasses; i++)
		fprintf(fptr, "\n\t\t\t<li style=\"font-size:25px; margin-top: 10px; margin-left: 25px\";><a href=\"%s.html\">%s</a></li>", array[i][0].cat, array[i][0].cat);	
	fprintf(fptr, "\n\t\t</ul>\n\t</body>\n</html>");
	fclose(fptr);
	
	for(i = 0; i < nClasses; i++){
		strcpy(filepath, "./www/");
		strcat(filepath, array[i][0].cat);
		strcat(filepath, ".html");
		fptr = fopen(filepath, "w");
		if(!fptr){
			fprintf(stderr, "Impossivel abrir o ficheiro %s", filepath);
			return;
		}
		fprintf(fptr, "<html>\n\t<head>\n\t\t<title>%s - Symposium %d</title>\n\t</head>\n",array[i][0].cat, ano);
		fprintf(fptr, "\t<body>\n\t\t<h1 style=\"margin-left: 25px\"><a href=\"index.html\">Voltar para o menu</a></h1>\n");
		fprintf(fptr, "\t\t<h1>%s</h1>\n", array[i][0].cat);
		fprintf(fptr, "\t\t<dl style=\"margin-left: 50px\">\n");
		for(j = 0; j < nMedsClasse[i]; j++){
			fprintf(fptr, "\t\t\t<dt style=\"font-size:25px; margin-top: 30px\";>%s</dt>\n", array[i][j].nome);
			fprintf(fptr, "\t\t\t<dd style=\"font-size:20px\";>-	Codigo: %d</dd>", array[i][j].cod);
			fprintf(fptr, "\t\t\t<dd style=\"font-size:20px\";>-	Preco: %.2f</dd>", array[i][j].preco);
			fprintf(fptr, "\t\t\t<dd style=\"font-size:20px\";>-	Composicao: %s</dd>", array[i][j].comp);
			fprintf(fptr, "\t\t\t<dd style=\"font-size:20px\";>-	Fabricante: %s</dd>", array[i][j].fabr);
			fprintf(fptr, "\t\t\t<dd style=\"font-size:20px\";>-	Equivalentes: %s</dd>", array[i][j].equ);
		}
		fprintf(fptr, "\t\t</dl>\n");
		fprintf(fptr, "\t</body>\n</html>");
		fclose(fptr);
	}
	
	printf("Pagina HTML gerada. A abrir... './www/index.html'\n");
	system("x-www-browser ./www/index.html");

}
void yyerror (char *s) {fprintf (stderr, "%d:%s\n", yylineno, s);} 


