// Ejemplo (absurdo) sintactico-semantico sin errores.
// Comprobad el resultado con la funcion "mostraTDS" 
{
  int a;
  read(a);
  bool b[7];
  int i;

  for (i = 0; i < 7; i++) {  
    b[i] = a > 0 ; 
    read (a);
  }

  int c[27];
  int j;
  for (j = 0; j < 27; j += 1) {  // Segun el boletin expresionOpcional es expresion | token_ID TOKEN_= expresion| vacio (eso causa error aqui ya que j+= 1 es tratada como expresionOpcional, para solucionarlo he cambiado una de las interpretaciones en concreto (token_ID TOKEN_= expresion) -> (token_ID operadorAsignacion expresion) para solucionarlo
    c[j] = j;
  }

  int d;
  bool e;
  d = c[4];
  e = b[4] && ( d > 0 );
}
