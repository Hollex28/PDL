/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_ASIN_H_INCLUDED
# define YY_YY_ASIN_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    MAS_ = 258,
    MENOS_ = 259,
    POR_ = 260,
    DIV_ = 261,
    PARA_ = 262,
    PARC_ = 263,
    IGUAL_ = 264,
    NOIGUAL_ = 265,
    MASIGUAL_ = 266,
    MENOSIGUAL_ = 267,
    PORIGUAL_ = 268,
    DIVIGUAL_ = 269,
    INCREMENTO_ = 270,
    DECREMENTO_ = 271,
    AND_ = 272,
    OR_ = 273,
    MENOR_ = 274,
    MAYOR_ = 275,
    MENORIG_ = 276,
    MAYORIG_ = 277,
    MODULO_ = 278,
    NO_ = 279,
    ASIG_ = 280,
    LLAVEA_ = 281,
    LLAVEC_ = 282,
    CORCHETEA_ = 283,
    CORCHETEC_ = 284,
    PUNTCOMA_ = 285,
    INT_ = 286,
    BOOL_ = 287,
    TRUE_ = 288,
    FALSE_ = 289,
    IF_ = 290,
    ELSE_ = 291,
    FOR_ = 292,
    READ_ = 293,
    PRINT_ = 294,
    CTE_ = 295,
    ID_ = 296
  };
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_ASIN_H_INCLUDED  */
