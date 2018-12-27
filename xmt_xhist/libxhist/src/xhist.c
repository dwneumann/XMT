/************************************************************************
*   $Version:$
*   Package	: xhist
*   Purpose : This file contains the function xhist_write(), 
*         which can be used to write the in-memory table to an
*         arbitrary file descriptor, and an encapsulation function
*         xhist_logdev(), to allow that file descriptor to be set
*         from the calling program.  By not passing the file
*         descriptor to the xhist_write() function, we can install
*         the xhist_write() function as a signal handler or atexit
*         handler.
*         Use of fprintf(stderr,"...) is parameterized so it can be
*         replaced with whatever error handling infrastructure is
*         available on the target environment.
*
*   Functions	:
*	void	xhist_logdev(int fd)
*	void	xhist_write()
*
*   Copyright (c) 1998	Neumann & Associates Information Systems Inc.
*   All Rights reserved.	legal.info@neumann-associates.com
************************************************************************/

#ifndef lint
static const char xhist_c_id[] = "@(#) xhist::xhist.c	$Version:$";
#endif

#define __xhist_c

/* pick up system configuration, whether using autoconf or XMT build */
#if !defined(USING_XMTBUILD)
#include <config.h> 
#endif

/* include stdio.h or make fprintf() and fflush() a no-op */
#if HAVE_STDIO_H
# include <stdio.h>
#else
# define fprintf(fd, fmt, msg) ;
# define fflush(fd) ;
#endif

/* include errno.h & string.h or make strerror() a non-specific message */
#if HAVE_ERRNO_H
# if HAVE_STRING_H
#  include <errno.h>
#  include <string.h>
# endif
#else
# define strerror(errno) "system error"
#endif

/* include unistd.h or declare close() & write() implicitly */
#if HAVE_UNISTD_H
# include <unistd.h>
#endif

#if !defined(NULL)
# define NULL ((void *)0)
#endif

#include "xhist.h"

#define BACKOUT_IF(ex, msg)	\
	if (ex) { fprintf(stderr, "%s\n", msg); goto backout; }

long	xhist_tbl[ XHIST_SIZE ]		= {0};
int		xhist_tail		= 0;
int		xhist_logfd		= -1;

/************************************************************************
*   Synopsis:
*	void	xhist_add(short filenum, short linenum)
*
*   Purpose:
*	Appends {filenum, linenum} to execution history log.
*	This is the function call equivalent to the _XHIST macro.
* 
*   Parameters: 
*	short	filenum	: index of filename in filemap
*	short	linenum	: line number in source file
* 
*   Values Returned: 
*	none	 
* 
***********************************************************************/
void	xhist_add( short filenum, short linenum)
{
    xhist_tbl[xhist_tail] = ((filenum << 16) | linenum);
    xhist_tail = ++xhist_tail % XHIST_SIZE;
}


/************************************************************************
*   Synopsis:
*	void	xhist_logdev(int fd)
*
*   Purpose:
*	Sets the execution history log device to the open file descriptor <fd>.
*	<fd> must permit writing of binary data but need not be seekable.
* 
*   Parameters: 
*	int	fd: file descriptor to write to
* 
*   Values Returned: 
*	none	 
* 
***********************************************************************/
void	xhist_logdev(int fd)
{
    xhist_logfd = fd;
}

/************************************************************************
*   Synopsis:
*	void	xhist_write()
*
*   Purpose:
*	Writes in-memory table to the log device 
*       specified via xhist_logdev().
* 
*   Parameters: 
*	none	 
* 
*   Values Returned: 
*	none	 
* 
***********************************************************************/
void	xhist_write()
{
    short		i;


    BACKOUT_IF( xhist_logfd < 0, "invalid log device" );


    /*
     *  write the size of our integer datatype.
     */

    i = sizeof(int);
    BACKOUT_IF( write( xhist_logfd, (char *) &i, sizeof(i) ) < sizeof(i), strerror(errno) );


    /*
     *  write the index of the tail pointer
     */

    BACKOUT_IF( write( xhist_logfd, (char *) &xhist_tail, sizeof( xhist_tail ) ) 
    	< sizeof( xhist_tail ), strerror(errno) );


    /*
     *  now write XHIST_SIZE entries from the table to the log device
     */
    
    for ( i = 0; i < XHIST_SIZE; ++i )
    {
	BACKOUT_IF( write( xhist_logfd, (char *) &xhist_tbl[i], 
		    sizeof( xhist_tbl[i] ) ) < sizeof( xhist_tbl[i] ), strerror(errno) );
    }

backout:
    close(xhist_logfd);
    fflush(stderr);
}
