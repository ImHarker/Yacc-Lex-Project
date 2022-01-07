%{
#include "y.tab.h"
#include <stdlib.h>
#include <stdio.h>
%}

%%
[ |\t|\n]+ 							;
(\/-.*-\/)							printf("Comentario: %s\n", yytext);
[1-9]+[0-9]*						{yylval.num = atoi(yytext); return Int; }
[0-9]+[.][0-9]*						{yylval.fnum = atof(yytext); return Float; }
[A-Za-z]+							{yylval.str = strdup(yytext); return String; }
"["									{yylval.str = strdup(yytext); return RBLeft;}
"]"									{yylval.str = strdup(yytext); return RBRight;}
"("									{yylval.str = strdup(yytext); return BLeft;}
")"									{yylval.str = strdup(yytext); return BRight;}
";"									{yylval.str = strdup(yytext); return Semicolon;}
"/"									{yylval.str = strdup(yytext); return Slash;}
"-"									{yylval.str = strdup(yytext); return Hyphen;}
"{"									{yylval.str = strdup(yytext); return CBLeft;}
"}"									{yylval.str = strdup(yytext); return CBRight;}
","									{yylval.str = strdup(yytext); return Comma;}
"."									{yylval.str = strdup(yytext); return Dot;}
":"									{yylval.str = strdup(yytext); return DDot;}
.									printf("Unexpected char %s\n",yytext);

%%
int yywrap(void)        
{
    return -1;           
}
