%{ /* DO NOT REMOVE THIS LINE */

/************************************************************************
 *
 *   Name               : xhist_instrument.l
 *   Subsystem          : xhist_instrument
 *   Purpose            :
 *      Lexical definitions for src code instruction trace instrumenter.
 *      Compile as:
 *              lex xhist_instrument.l
 *              cc lex.yy.c -o xhist_instrument -ll
 *      Run as:
 *              errcount < err.h
 *
 *   Date of Creation   : Sep 21, 1994
 *   File Name          : xhist_instrument.l
 *   Version Number     : 1.4
 *   Last Updated       : 94/09/22
 *
 *   Author             : Dean Neumann
 *   Notes:
 *
 *  Copyright (c) 1998  Neumann & Associates Information Systems Inc.
 *                      legal.info@neumann-associates.com
 *  Rights & restrictions governed by the GNU GPL; See ../COPYING for details.
 ************************************************************************/

#ifndef lint
static char xhist_instrument_l_sccsid[] = "@(#) \txhist:xhist_instrument.l\t1.4\t94/09/22";
#endif

#define __xhist_instrument_l

#include <stdio.h>
#define TRUE    1
#define FALSE   0
#define TRACE   "_XH"

char    in_rtn          = FALSE;        /* TRUE if inside a routine     */
char    debug           = FALSE;        /* TRUE if debugging scanner    */
char    instrument      = TRUE;         /* TRUE if instrumenting should occur */

%}

word    [a-zA-Z0-9_]+
operator        [-+<>=!\^\(]

%%
^[ \t]*\/\*[ \t]*xhist[ \t]+debug[ \t]+TRUE[ \t]*\*\/\n {
/* "xhist debug TRUE" inside a comment enables tracing          */
    debug = TRUE;
    printf( "%s%s",  (debug ? "<DEBUG ON>" : ""), yytext );
}

^[ \t]*\/\*[ \t]*xhist[ \t]+debug[ \t]+FALSE[ \t]*\*\/\n        {
/* "xhist debug FALSE" inside a comment disables tracing        */
    printf( "%s%s",  (debug ? "<DEBUG OFF>" : ""), yytext );
    debug = FALSE;
}

^[ \t]*\/\*[ \t]*xhist[ \t]+instrument[ \t]+TRUE[ \t]*\*\/\n    {
/* "xhist instrument TRUE" inside a comment enables instrumentation */
    instrument = TRUE;
    printf( "%s%s",  (debug ? "<INSTRUMENTATION ON>" : ""), yytext );
}

^[ \t]*\/\*[ \t]*xhist[ \t]+instrument[ \t]+FALSE[ \t]*\*\/\n   {
/* "xhist instrument FALSE" inside a comment disables instrumentation */
    instrument = FALSE;
    printf( "%s%s",  (debug ? "<INSTRUMENTATION OFF>" : ""), yytext );
}

^\{[ \t]*$      {
/* an opening brace in column 1 indicates a procedure start */
    in_rtn = TRUE;
    printf( "%s%s",  (debug ? "<FUNC START>" : ""), yytext );
}

^\}             {
/* a closing brace in column 1 indicates a procedure end */
    in_rtn = FALSE;
    printf( "%s%s",  (debug ? "<FUNC END>" : ""), yytext );
}

^[ \t]*{word}\**[ \t]+\(?\**{word}.*\n  {
/* an identifier followed by whitespace then another identifier 
   indicates a declaration */
    printf( "%s%s",  (debug ? "<DECL>" : ""), yytext );
}

.*[ \t]*for[ \t]*\(.*\;.*$      {
/* "for" keyword indicates a for statement */
    printf( "%s%s",  (debug ? "<FOR STMT>" : ""), yytext );
}

[ \t]*return[ \t\(]+.*\)*\;     {
/* "return" keyword indicates a return statement */
    if ( in_rtn )
    {
        printf( "%s{%s;%s}",  (debug ? "<RETURN STMT>" : ""), 
              ( instrument ? TRACE : "" ), yytext );
    }
    else
    {
        printf( "%s%s",  (debug ? "<RETURN STMT OUTSIDE FUNC>" : ""), 
                yytext );
    }
}

.*{operator}.*\;        {
/* a line containing an operator and terminating with a semicolon 
   indicates a statement */
    if ( in_rtn )
    {
        printf( "%s%s%s",  (debug ? "<STMT>" : ""), yytext, 
              ( instrument ? TRACE : "" ) );
    }
    else
    {
        printf( "%s%s",  (debug ? "<STMT OUTSIDE FUNC>" : ""), yytext );
    }
}

\n  {
/* a carriage return is simply echo'ed */
    printf( "%s", yytext );
}

.   {
/* anything else is simply echo'ed */
    printf( "%s", yytext );
}

%%

yywrap()
{
    return( 1 );
}

main()
{
    yylex();
}
