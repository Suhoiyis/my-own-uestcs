%{
#include<stdlib.h>
#include<string.h>
#include<stdio.h> 
enum yytokentype {
	num_INT = 258,
	num_FLOAT = 259,

	Y_ID = 260,

	Y_INT = 261,
	Y_VOID = 262,
	Y_CONST = 263,
	Y_IF = 264,
	Y_ELSE = 265,
	Y_WHILE = 266,
	Y_BREAK = 267,
	Y_CONTINUE = 268,
	Y_RETURN = 269,

	Y_ADD = 270,
	Y_SUB = 271,
	Y_MUL = 272,
	Y_DIV = 273,
	Y_MODULO = 274,
	Y_LESS = 275,
	Y_LESSEQ = 276,
	Y_GREAT = 277,
	Y_GREATEQ = 278,
	Y_NOTEQ = 279,
	Y_EQ = 280,
	Y_NOT = 281,
	Y_AND = 282,
	Y_OR = 283,
	Y_ASSIGN = 284,

	Y_LPAR = 285,
	Y_RPAR = 286,
	Y_LBRACKET = 287,
	Y_RBRACKET = 288,
	Y_LSQUARE = 289,
	Y_RSQUARE = 290,
	Y_COMMA = 291,
	Y_SEMICOLON = 292,

	Y_FLOAT = 293
};

typedef union _YYword{
	int		get;
	int		i_key;
	float   d_key;
	char*	str;
}_YYword;

%}

	_YYword wd;

%%
[ \t\n] ;
(\/\/.*\n)|(\/\*.*\*\/) ;

int { return Y_INT; }
float { return Y_FLOAT; }
void { return Y_VOID; }
const { return Y_CONST; }
if { return Y_IF; }
else { return Y_ELSE; }
while { return Y_WHILE; }
break { return Y_BREAK; }
continue { return Y_CONTINUE; }
return { return Y_RETURN; }
"+" { return Y_ADD; }
"-" { return Y_SUB; }
"*" { return Y_MUL; }
"/" { return Y_DIV; }
"%" { return Y_MODULO; }
"<" { return Y_LESS; }
"<=" { return Y_LESSEQ; }
">" { return Y_GREAT; }
">=" { return Y_GREATEQ; }
"!=" { return Y_NOTEQ; }
"==" { return Y_EQ; }
"!" { return Y_NOT; }
"&&" { return Y_AND; }
"||" { return Y_OR; }
"=" { return Y_ASSIGN; }
"(" { return Y_LPAR; }
")" { return Y_RPAR; }
"{" { return Y_LBRACKET; }
"}" { return Y_RBRACKET; }
"[" { return Y_LSQUARE; }
"]" { return Y_RSQUARE; }
"," { return Y_COMMA; }
";" { return Y_SEMICOLON; }

-?[0-9]+ { wd.i_key = atoi(yytext); return num_INT; }
-?[0-9]*\.[0-9]+ { wd.d_key = atof(yytext); return num_FLOAT; }
[a-zA-Z_][a-zA-Z0-9_]* { wd.str = strdup(yytext); return Y_ID; }
0x[0-9a-fA-F]+ { wd.i_key = strtol(yytext, NULL, 16); return num_INT; }
%%
    
int main(int argc, char **argv) 
{
    int inf;
    while((inf = yylex()) != 0) {
		if(inf>260){
			if(inf <= 269 || inf == 293) {
                char words[10] = "KEYWORD";
                printf("<%d, %s>\n", inf, words);
            }else if(inf<= 284) {
                char words[10] = "OPERATOR";
                printf("<%d, %s>\n", inf, words);
            }else if(inf <= 292) {
                char words[10] = "SYMBOL";
                printf("<%d, %s>\n", inf, words);
            }else{
                printf("<UNKNOWN>\n");
            }            
        }  
        else{
     		switch (inf) {
				case Y_ID:
					printf("<%d, %s>\n", inf, wd.str);
                    free(wd.str);                    
					break;
				case num_INT:
					printf("<%d, %d>\n", inf, wd.i_key);
					break;
				case num_FLOAT:
					printf("<%d, %f>\n", inf, wd.d_key);
					break;
				default:
                    printf("<UNKNOWN>\n");
                    break;					
            	}	
    		}
		}
    return 0;
}
int yywrap()
{
	return 1;
} 
