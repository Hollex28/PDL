/*****************************************************************************/
/**  Analizador Lexico                      2018-2019                       **/
/** ALUMNOS:                                                                **/
/** Antonio Gallego Gallego                          <angalga2@inf.upv.es>  **/
/** Adrian Tendero Lara                              <adtenla@inf.upv.es>   **/
/** Jordi Almendros Granero                      <joralgra@etsiamn.upv.es>  **/
/*****************************************************************************/
%{
#include <stdio.h>
#include <string.h>
#include "header.h"
#include "asin.h"
%}
/*----------------------------------------------------------------------
  Dado que las funciones "input()" y "unput(c)" son costosas y no las
  utilizaremos, evitaremos que se generen automaticamente sus rutinas
  correspondientes desactivandolas mediante las siguientes opciones:
----------------------------------------------------------------------*/
%option noinput
%option nounput
/*----------------------------------------------------------------------
  Para mantener el numero de linea actual en la variable global yylineno
----------------------------------------------------------------------*/
%option yylineno

delimitador     [ \t\n]+
comentario      \/\/.*
digito          [0-9]
letra			[a-zA-Z]
constante       ({digito}+|{digito}+"."|{digito}*"."{digito}+)
identificador 	{letra}({letra}|{digito}|_)*

%%
{delimitador}   	{ ECHO;                                             }
{comentario}		{ ECHO;		              	                       }
"read"             	{ ECHO; return(READ_);                              }
"print"            	{ ECHO; return(PRINT_);                             }
"if"               	{ ECHO; return(IF_);                                }
"else"              { ECHO; return(ELSE_);                              }
"for"              	{ ECHO; return(FOR_);                               }
"int"               { ECHO; return(INT_);                               }
"bool"             	{ ECHO; return(BOOL_);                              }
"true"             	{ ECHO; return(TRUE_);                              }
"false"            	{ ECHO; return(FALSE_);                             }
"&&"             	{ ECHO; return(AND_);                               }
"||"             	{ ECHO; return(OR_);                                }
"+="             	{ ECHO; return(MASIGUAL_);                          }
"-="             	{ ECHO; return(MENOSIGUAL_);                        }
"*="             	{ ECHO; return(PORIGUAL_);                          }
"/="             	{ ECHO; return(DIVIGUAL_);                          }
"=="             	{ ECHO; return(IGUAL_);                             }
"!="                { ECHO; return(DIFERENTE_);                         }
"<="             	{ ECHO; return(MENORIGUAL_);                        }
">="             	{ ECHO; return(MAYORIGUAL_);                        }
"++"             	{ ECHO; return(INCREMENTO_);                        }
"--"             	{ ECHO; return(DECREMENTO_);                        }
"+"             	{ ECHO; return(MAS_);                               }
"-"             	{ ECHO; return(MENOS_);                             }
"*"             	{ ECHO; return(POR_);                               }
"/"             	{ ECHO; return(DIV_);                               }
"="             	{ ECHO; return(ASIG_);                              }
"<"             	{ ECHO; return(MENOR_);                             }
">"             	{ ECHO; return(MAYOR_);                             }
"%"             	{ ECHO; return(MOD_);                               }
"!"             	{ ECHO; return(NOT_);                               }
"("             	{ ECHO; return(PARA_);  	                        }
")"             	{ ECHO; return(PARC_);                              }
"{"             	{ ECHO; return(LLAVEA_);                            }
"}"             	{ ECHO; return(LLAVEC_);                            }
"["             	{ ECHO; return(CORCHETEA_);                         }
"]"             	{ ECHO; return(CORCHETEC_);    					    }
";"             	{ ECHO; return(PUNTOCOMA_);    					    }
{identificador}		{ ECHO; yylval.ident = strdup(yytext); return(ID_); }
{constante}			{ ECHO; yylval.cent = atoi(yytext); return(CTE_);   }
.               	{ yyerror("Caracter desconocido");                  }
%%
