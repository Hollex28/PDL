/*****************************************************************************/
/**  Analizador Sintactico - Bison          2018-2019                       **/
/** ALUMNOS:                                                                **/
/** Antonio Gallego Gallego                          <angalga2@inf.upv.es>  **/
/** Adrian Tendero Lara                              <adtenla@inf.upv.es>   **/
/** Jordi Almendros Granero                      <joralgra@etsiamn.upv.es>  **/
/*****************************************************************************/
%{
    #include <stdio.h>
    #include <string.h>
    #include "libtds.h"
    #include "header.h"
    #include "libgci.h"
%}

%union {
    EXP exp;
    char* ident;
    int cent;
}
%token <ident> ID_
%token <cent> CTE_
%token MAS_ MENOS_ POR_ DIV_ ASIG_
%token MENOR_ MAYOR_ MOD_ NOT_ AND_ OR_
%token MASIGUAL_ MENOSIGUAL_ PORIGUAL_ DIVIGUAL_ IGUAL_ MENORIGUAL_ MAYORIGUAL_ DIFERENTE_
%token INCREMENTO_ DECREMENTO_
%token PARA_ PARC_ LLAVEA_ LLAVEC_ CORCHETEA_ CORCHETEC_ PUNTOCOMA_
%token <cent> INT_ BOOL_ 
%token READ_ PRINT_ IF_ FOR_ TRUE_ FALSE_ ELSE_

%type <cent> tipoSimple instruccionIteracion
%type <cent> operadorAsignacion operadorLogico operadorIgualdad operadorRelacional
%type <cent> operadorMultiplicativo operadorUnario operadorAditivo operadorIncremento

%type <exp> expresion expresionSufija expresionOpcional expresionIgualdad expresionRelacional instruccionAsignacion
%type <exp> expresionAditiva expresionMultiplicativa expresionUnaria constante declaracion

%%


programa
    : LLAVEA_ secuenciaSentencias LLAVEC_
    {   //GCI 
        emite(FIN,crArgNul(),crArgNul(),crArgNul());}
    ;

secuenciaSentencias
    : sentencia
    | secuenciaSentencias sentencia
    ;

sentencia
    : declaracion
    | instruccion
    ;

declaracion
    : tipoSimple ID_ PUNTOCOMA_ 
    {
        if ( !insTSimpleTDS($2,$1,dvar) )
            yyerror ("Identificador repetido");
        else dvar += TALLA_TIPO_SIMPLE; 
    }
    | tipoSimple ID_ ASIG_ constante PUNTOCOMA_
    {

        if ($1 != $4.tipo)
           yyerror ("Error de Tipos");
        else
        {
            if ( !insTSimpleTDS($2,$1,dvar) )
                yyerror ("Identificador repetido");
            else dvar += TALLA_TIPO_SIMPLE;
        
        SIMB s = obtenerTDS($2);

        emite(EASIG, crArgPos($4.pos), crArgNul(), crArgPos(s.desp));
         
        }





    }
    | tipoSimple ID_ CORCHETEA_ CTE_ CORCHETEC_ PUNTOCOMA_ 
    {
        int numelem = $4;
        if (numelem <= 0)
            {
                yyerror("Talla inapropiada del array");
                numelem = 0;
            }
        if ( !insTVectorTDS($2, T_ARRAY, dvar, $1, numelem) )
            yyerror ("Identificador repetido");
        else dvar += numelem * TALLA_TIPO_SIMPLE;

        
    }
    ;

tipoSimple
    : INT_ { $$ = T_ENTERO; }
    | BOOL_  { $$ = T_LOGICO; }
    ;

instruccion
    : LLAVEA_ listaInstrucciones LLAVEC_
    | instruccionEntradaSalida
    | instruccionAsignacion
    | instruccionSeleccion
    | instruccionIteracion
    ;

listaInstrucciones
    : listaInstrucciones instruccion
    |
    ;


instruccionAsignacion
    : ID_ operadorAsignacion expresion PUNTOCOMA_
	{ 	
        SIMB s = obtenerTDS($1);
		if (s.tipo == T_ERROR) 
			yyerror("Objeto no declarado");
		else if ( !((s.tipo != T_ERROR) && (s.tipo == $3.tipo)) )
			yyerror("Error de tipos en la 'instruccionAsignacion'");
		else $$.tipo = s.tipo;

        $$.pos = creaVarTemp();
        if($2 == EASIG){
            emite(EASIG, crArgPos($3.pos), crArgNul(), crArgPos($$.pos));
        }else {          
            emite($2, crArgPos(s.desp), crArgPos($3.pos), crArgPos($$.pos));
            
        }
        emite(EASIG, crArgPos($$.pos), crArgNul(), crArgPos(s.desp));
	}
    
    | ID_ CORCHETEA_ expresion CORCHETEC_ operadorAsignacion expresion PUNTOCOMA_
	{
		SIMB s = obtenerTDS($1);
		if (s.tipo == T_ERROR) 
			yyerror("Objeto no declarado");
		else if ( !((s.telem == $6.tipo) && ($3.tipo == T_ENTERO) && (s.tipo == T_ARRAY) ) )
			yyerror("Error del array en la 'instruccionAsignacion'");
		else {
            $$.tipo = s.telem;
        }
        
        $$.pos = creaVarTemp();
        if ($5 != EASIG) {
            emite(EAV, crArgPos(s.desp), crArgPos($3.pos), crArgPos($$.pos));
            emite($5, crArgPos($$.pos), crArgPos($6.pos), crArgPos($$.pos));
        } else {
            emite($5, crArgPos($6.pos), crArgNul(), crArgPos($$.pos));
        }
        emite(EVA, crArgPos(s.desp), crArgPos($3.pos), crArgPos($$.pos));        

	}
    ;

instruccionEntradaSalida
    : READ_ PARA_ ID_ PARC_ PUNTOCOMA_
        { SIMB s = obtenerTDS($3);
        if (s.tipo == T_ERROR)
            yyerror("Tipo no declarado");
        else if (s.tipo != T_ENTERO)
            yyerror("READ es para Tipo Entero");

            //GCI
            emite(EREAD,crArgNul(),crArgNul(),crArgPos(s.desp));

        }
        

    | PRINT_ PARA_ expresion PARC_ PUNTOCOMA_
        {
            if ($3.tipo != T_ENTERO){
               yyerror("PRINT es para Tipo Entero");
            }
	    else{
            //GCI
            emite(EWRITE, crArgNul(), crArgNul(), crArgPos($3.pos));
        }        
    }

    ;

instruccionSeleccion
    : IF_ PARA_ expresion PARC_ 
        { if ($3.tipo != T_ERROR && $3.tipo != T_LOGICO) 
            yyerror("La expresion del if debe ser de tipo logica");
          
          $<cent>$ = creaLans(si);
          emite(EIGUAL, crArgPos($3.pos), crArgEnt(FALSE), crArgEtq($<cent>$));
        }        
        instruccion ELSE_
            {
                $<cent>$ = creaLans(si);
                emite(GOTOS, crArgNul(), crArgNul(), crArgEtq($<cent>$));
                completaLans($<cent>5, crArgEtq(si));
            }
        instruccion
            {
                completaLans($<cent>8, crArgEtq(si));
            }
    ;

instruccionIteracion
    : FOR_ PARA_ expresionOpcional PUNTOCOMA_
        {
            //5
            $<cent>$ = si;
        }

    expresion PUNTOCOMA_
        {
            //Final del for
            $<cent>$ = creaLans(si); 
            emite(EIGUAL, crArgPos($6.pos), crArgEnt(FALSE), crArgEtq($<cent>$));
        }
        {
            //Entrar en el bloque
            $<cent>$ = creaLans(si); 
            emite(GOTOS, crArgNul(), crArgNul(), crArgEtq($<cent>$));
        }
        {       
            $<cent>$ = si;
        }

    expresionOpcional PARC_ 
        {
            //Entrar a la condición
            emite(GOTOS, crArgNul(), crArgNul(), crArgEtq($<cent>5));
            //Rellena Entrar en el bloque
            completaLans($<cent>9, crArgEtq(si));
        }
    instruccion
	{
		if ($6.tipo != T_LOGICO){
			yyerror("La Guarda del bucle for tiene que ser logica");
			}
        
        emite(GOTOS, crArgNul(), crArgNul(), crArgEtq($<cent>10));
        //Rellena final de for
        completaLans($<cent>8, crArgEtq(si));
        
	}
    ;

expresionOpcional
    : expresion	{ $$.tipo = $1.tipo; $$.valor = $1.valor;$$.pos = $1.pos;}
    | ID_ ASIG_ expresion
    { 	
        $$.tipo = T_ERROR;
        SIMB s = obtenerTDS($1);
		if (s.tipo == T_ERROR) 
			yyerror("Objeto no declarado");
		else{
			if (!( (s.tipo == $3.tipo && s.tipo == T_ENTERO)||(s.tipo == $3.tipo && s.tipo == T_LOGICO) ))
				yyerror("Error de tipos en la 'instruccionAsignacion'");
			else {
					$$.tipo = s.tipo;
			        $$.pos = creaVarTemp();
					emite(EASIG, crArgPos($3.pos), crArgNul(), crArgPos($$.pos));
					emite(EASIG, crArgPos($$.pos), crArgNul(), crArgPos(s.desp));
			}
		}
         
    }// Ahora solo hace emite si y solo si $3.tipo == s.tipo y los tipos != T_ERROR
/*Pegarle un vistazo ha esta expresion que no se me ocurre como puede ser (A = True && False) una cosa asi*/
    | { $$.tipo = T_ERROR; }
    ;

expresion
    : expresionIgualdad { $$.tipo = $1.tipo; $$.valor = $1.valor;$$.pos = $1.pos;} 
    | expresion operadorLogico expresionIgualdad 
		{
            $$.tipo = T_ERROR;
            if ( $1.tipo != T_ERROR && $3.tipo != T_ERROR )
            {
                if ( $1.tipo != $3.tipo ) {
                    yyerror( "Los tipos no coinciden en la expresion" );                
                } else {
                    $$.tipo = T_LOGICO;
                    if ($2 == OP_OR)
                        $$.valor = $1.valor || $3.valor ? TRUE : FALSE;
                    else if ($2 == OP_AND)
                        $$.valor = $1.valor && $3.valor ? TRUE : FALSE;

                   
                }
            }
            $$.pos = creaVarTemp();
            int overrideValue = $2 == OP_AND ? FALSE : TRUE;
            emite(EASIG, crArgPos($3.pos), crArgNul(), crArgPos($$.pos));
            emite(EDIST, crArgPos($1.pos), crArgEnt(overrideValue), crArgEtq(si + 2));
            emite(EASIG, crArgEnt(overrideValue), crArgNul(), crArgPos($$.pos));
        }
    ;

expresionIgualdad
    : expresionRelacional { $$.tipo = $1.tipo; $$.valor = $1.valor; $$.pos = $1.pos;}
    | expresionIgualdad operadorIgualdad expresionRelacional
        {
            $$.tipo = T_ERROR;
            if ( $1.tipo != T_ERROR && $3.tipo != T_ERROR )
            {
                if ( $1.tipo != $3.tipo ) {
                    yyerror( "Los tipos no coinciden en la igualdad" );
                } else if ( $1.tipo == T_ARRAY ) {
                    yyerror( "El operador de igualdad no se puede aplicar en los arrays" );                
                } else {
                    $$.tipo = T_LOGICO;
                    if ($2 == EIGUAL)
                        $$.valor = $1.valor == $3.valor ? TRUE : FALSE;
                    else if ($2 == EDIST)
                        $$.valor = $1.valor != $3.valor ? TRUE : FALSE;
                }
            }
            $$.pos = creaVarTemp();
            emite(EASIG, crArgEnt(TRUE), crArgNul(), crArgPos($$.pos));
            emite($2, crArgPos($1.pos), crArgPos($3.pos), crArgEtq(si + 2));
            emite(EASIG, crArgEnt(FALSE), crArgNul(), crArgPos($$.pos));
        }
    ;

expresionRelacional
    : expresionAditiva { $$.tipo = $1.tipo; $$.valor = $1.valor; $$.pos = $1.pos; }
    | expresionRelacional operadorRelacional expresionAditiva
	{
		$$.tipo = T_ERROR;
		if ($1.tipo != T_ERROR && $3.tipo != T_ERROR){
			if ($1.tipo != $3.tipo) {
				yyerror("Los tipos de la expresion Relacional son diferentes");
			}
			else if ($1.tipo != T_ENTERO){
				yyerror("La expresion relacional con expresion logica, las expresiones relacionales solo trabajan con Enteros");
			}else{
				$$.tipo = T_LOGICO;
				if ($2 == EMAY)
					$$.valor = $1.valor > $3.valor ? TRUE : FALSE;
				if ($2 == EMEN)
					$$.valor = $1.valor < $3.valor ? TRUE : FALSE;
				if ($2 == EMAYEQ)
					$$.valor = $1.valor >= $3.valor ? TRUE : FALSE;
				if ($2 == EMENEQ)
					$$.valor = $1.valor <= $3.valor ? TRUE : FALSE;		
			}
		}

        $$.pos = creaVarTemp();
		emite(EASIG, crArgEnt(TRUE), crArgNul(), crArgPos($$.pos));
		emite($2, crArgPos($1.pos), crArgPos($3.pos), crArgEtq(si + 2));
		emite(EASIG, crArgEnt(FALSE), crArgNul(), crArgPos($$.pos)); 

	}
    ;

expresionAditiva 
    : expresionMultiplicativa { $$.tipo = $1.tipo; $$.valor = $1.valor;  $$.pos = $1.pos; }
    | expresionAditiva operadorAditivo expresionMultiplicativa
	{
	$$.tipo = T_ERROR;
        if ($1.tipo != T_ERROR && $3.tipo != T_ERROR) {
            if ($1.tipo != $3.tipo) {
                yyerror("Los tipos de la expresion additiva no son iguales");
            } else if ($1.tipo != T_ENTERO) {
                yyerror("La Operacion Aditiva solo trabaja con tipo Entero");
            } else {
                $$.tipo = T_ENTERO;

                if ($2 == ESUM)
                    $$.valor = $1.valor + $3.valor;
                else if ($2 == EDIF)
                    $$.valor = $1.valor - $3.valor;
            }
		}

        $$.pos = creaVarTemp();
		emite($2, crArgPos($1.pos), crArgPos($3.pos), crArgPos($$.pos));
       } 
    ;

expresionMultiplicativa
    : expresionUnaria { $$.tipo = $1.tipo; $$.valor = $1.valor; $$.pos = $1.pos;}
    | expresionMultiplicativa operadorMultiplicativo expresionUnaria
	{ $$.tipo = T_ERROR;
        if ($1.tipo != T_ERROR && $3.tipo != T_ERROR) {
            if ($1.tipo != $3.tipo) {
                yyerror("Tipos no coinciden en operacion multiplicativa");
            } else if ($1.tipo != T_ENTERO) {
                yyerror("Operacion multiplicativa solo acepta argumentos enteros");
            } else {
                $$.tipo = T_ENTERO;

                if ($2 == EMULT)
                    $$.valor = $1.valor * $3.valor;
                if ($2 == EDIVI) {
                    if ($3.valor == 0) {
                        $$.tipo = T_ERROR;
                        yyerror("No se puede dividir entre 0");
                    } else {
                        $$.valor = $1.valor / $3.valor;
                    }
                    }if ($2 == RESTO) {
                        if ($3.valor == 0) {
                            $$.tipo = T_ERROR;
                            yyerror("No se puede dividir entre 0, y por tanto la operacion Modulo tampoco");
                        } else {
                            $$.valor = $1.valor % $3.valor;
                        }
                    }
            }
		} 
        $$.pos = creaVarTemp();
		emite($2, crArgPos($1.pos), crArgPos($3.pos), crArgPos($$.pos)); 
	}
    ;

expresionUnaria
    : expresionSufija { $$.tipo = $1.tipo; $$.valor = $1.valor; $$.pos = $1.pos; } 
    | operadorUnario expresionUnaria
    { 
        $$.tipo = T_ERROR;
        if ($2.tipo != T_ERROR){
            if ($2.tipo == T_ENTERO){
                if ($1 == OP_NOT){
                    yyerror("No se puede usar '!' en enteros");
                }else{
                    $$.tipo = T_ENTERO;
                    if ($1 == ESUM) {
                        $$.valor = $2.valor;
                    }
                    if ($1 == EDIF) {
                        $$.valor = -$2.valor;
                    }
                }
            }
            if ($2.tipo == T_LOGICO){
                if($1 == OP_NOT){
                    $$.tipo=T_LOGICO;
                    if($2.valor == FALSE){
                        $$.valor = TRUE;
                    }else{
                        $$.valor = FALSE;
                    }
                }else{
                    yyerror("Expresion Logica con Operacion Entera Invalida");
                }
            }
        }

        $$.pos = creaVarTemp();
        if ($1 == OP_NOT) {
            emite(EDIF, crArgEnt(1), crArgPos($2.pos), crArgPos($$.pos));
        } else {
            emite($1, crArgEnt(0), crArgPos($2.pos), crArgPos($$.pos));
        }

    }
    | operadorIncremento ID_
    {
        SIMB simb = obtenerTDS($2);
        $$.tipo = T_ERROR;
        if (simb.tipo == T_ERROR){
            yyerror("Variable no declarada");
        }
        else if (simb.tipo == T_ARRAY){
            yyerror("La variable es un vector sin indice");
        }
        else{
            $$.tipo = simb.tipo;
        }


		emite($1, crArgPos(simb.desp), crArgEnt(1), crArgPos($$.pos));
        emite($1, crArgPos(simb.desp), crArgEnt(1), crArgPos(simb.desp));
    }
    ;

expresionSufija
    : PARA_ expresion PARC_ { $$.tipo = $2.tipo; $$.valor = $2.valor; $$.pos = $2.pos;}
    | ID_ operadorIncremento  
        {
            $$.tipo = T_ERROR;
            SIMB s = obtenerTDS($1);
            if(s.tipo == T_ERROR){
                yyerror("Variable no declarada.");
            }else if (s.tipo == T_ARRAY){
                yyerror("El array no tiene indices por los cuales acceder");
            }else{
                $$.tipo = s.tipo;   
            }
   
            emite($2, crArgPos(s.desp), crArgEnt(1), crArgPos(s.desp));
        }
    | ID_ CORCHETEA_ expresion CORCHETEC_
        {
            SIMB simb = obtenerTDS($1);
            $$.tipo = T_ERROR;
            if (simb.tipo == T_ERROR){
                yyerror("Variable no declarada");
            }else if ( simb.tipo != T_ARRAY){
                yyerror("La variable no es un array, no se pueden poner indices");}
            else if($3.tipo != T_ENTERO)
                yyerror("Error de tipos para el array");
            else {
                if($3.tipo != T_ENTERO && (($3.valor < 0) || ($3.valor >= simb.nelem))){
                   yyerror("Indice invalido para el array");
                }else{
                    $$.tipo = simb.telem; }
            }

            $$.pos = creaVarTemp();
            emite(EAV, crArgPos(simb.desp), crArgPos($3.pos), crArgPos($$.pos));

        }
    | ID_
    {
        SIMB s = obtenerTDS($1);
        $$.tipo = T_ERROR;
        if(s.tipo == T_ERROR){
            yyerror("Variable no declarada.");    
        }else{
            $$.tipo = s.tipo;
        }
        $$.pos = s.desp;
    }
    | constante 
    {
	
        $$ = $1;
    }
    ;

constante
    : CTE_      {   
                    $$.tipo  = T_ENTERO;
                    $$.pos = creaVarTemp();
                    emite(EASIG, crArgEnt($1), crArgNul(), crArgPos($$.pos));
                    }
    | TRUE_     {   
                    $$.tipo  = T_LOGICO;
                    $$.pos = creaVarTemp();
                    emite(EASIG, crArgEnt(TRUE), crArgNul(), crArgPos($$.pos));
                    }
    | FALSE_    {   
                    $$.tipo  = T_LOGICO;
                    $$.pos = creaVarTemp();
                    emite(EASIG, crArgEnt(FALSE), crArgNul(), crArgPos($$.pos));
                }
    ;

operadorAsignacion
    : ASIG_         { $$ = EASIG;}
    | MASIGUAL_     { $$ = ESUM;}
    | MENOSIGUAL_   { $$ = EDIF;}
    | PORIGUAL_     { $$ = EMULT;}
    | DIVIGUAL_     { $$ = EDIVI;}
    ;

operadorLogico
    : AND_      { $$ = OP_AND;}
    | OR_       { $$ = OP_OR;}
    ;

operadorIgualdad
    : IGUAL_        { $$ = EIGUAL;}
    | DIFERENTE_    { $$ = EDIST;}
    ;

operadorRelacional
    : MAYOR_        { $$ = EMAY;}
    | MENOR_        { $$ = EMEN;}
    | MAYORIGUAL_   { $$ = EMAYEQ;}
    | MENORIGUAL_   { $$ = EMENEQ;}
    ;

operadorAditivo
    : MAS_      { $$ = ESUM;}
    | MENOS_    { $$ = EDIF;}
    ;

operadorMultiplicativo
    : POR_      { $$ = EMULT;}
    | DIV_      { $$ = EDIVI;}
    | MOD_      { $$ = RESTO;}
    ;

operadorUnario
    : MAS_      { $$ = ESUM;}
    | MENOS_    { $$ = EDIF;}
    | NOT_      { $$ = OP_NOT;}
    ;

operadorIncremento
    : INCREMENTO_ { $$ = ESUM;}
    | DECREMENTO_ { $$ = EDIF;}
    ;

%%
