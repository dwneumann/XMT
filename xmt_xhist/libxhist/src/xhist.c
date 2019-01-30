/************************************************************************
*   $Version: 5.2.2-22 [experimental] $
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
*	void	xhist_add(short filenum, short linenum)
*	void	xhist_mapfile(char *s)
*	void	xhist_version(char *s)
*	void	xhist_logdev(int fd)
*	void	xhist_write()
*
*   Copyright (c) 1998	Neumann & Associates Information Systems Inc.
*   All Rights reserved.	legal.info@neumann-associates.com
************************************************************************/
#define __xhist_c
#ifndef lint
static const char xhist_c_id[] = "@(#) xhist::xhist.c	$Version: 5.2.2-22 [experimental] $";
#endif


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

char xhist_buildtag[XHIST_VERSIONLENGTH]	= {0};
char xhist_mapfn[ XHIST_MAPFNLENGTH ]		= {0};
unsigned long	xhist_tbl[ XHIST_TBLSIZE ]	= {0};
unsigned long	xhist_tail			= 0;
int	xhist_logfd				= -1;

/************************************************************************
*   Synopsis:
*	void	xhist_add(unsigned short filenum, unsigned short linenum)
*
*   Purpose:
*	Appends (filenum, linenum) to execution history log.
*	This is a function call equivalent to the _XHIST macro.
* 
*   Parameters: 
*	short	filenum	: index of filename in filemap
*	short	linenum	: line number in source file
* 
*   Values Returned: 
*	none	 
* 
***********************************************************************/
void	xhist_add( unsigned short filenum, unsigned short linenum)
_XH_ADD(filenum, linenum);

/************************************************************************
*   Synopsis:
*	void	xhist_mapfile(char *s)
*
*   Purpose:
*	Stores the name of the mapfile needed to decode the file numbers 
*	recorded in the table.
* 
*   Parameters: 
*	char	*s : map filename string to store
* 
*   Values Returned: 
*	none	 
* 
***********************************************************************/
void	xhist_mapfile(char *s)
{
    memset( (void *) xhist_mapfn, (int) 0, (size_t) XHIST_MAPFNLENGTH );/*<XHIST>*/ _XH_ADD( 44706, 111 );/*</XHIST>*/
    (void) strncpy( xhist_mapfn, s, (size_t) XHIST_MAPFNLENGTH );/*<XHIST>*/ _XH_ADD( 44706, 112 );/*</XHIST>*/
    xhist_mapfn[XHIST_MAPFNLENGTH - 1] = '\0';/*<XHIST>*/ _XH_ADD( 44706, 113 );/*</XHIST>*/
}

/************************************************************************
*   Synopsis:
*	void	xhist_version(char *s)
*
*   Purpose:
*	Stores the version tag of the instrumented source
*	recorded in the table.
* 
*   Parameters: 
*	char	*s : version string to store
* 
*   Values Returned: 
*	none	 
* 
***********************************************************************/
void	xhist_version(char *s)
{
    memset( (void *) xhist_buildtag, (int) 0, (size_t) XHIST_MAPFNLENGTH );/*<XHIST>*/ _XH_ADD( 44706, 133 );/*</XHIST>*/
    strncpy( xhist_buildtag, s, (size_t) XHIST_VERSIONLENGTH );/*<XHIST>*/ _XH_ADD( 44706, 134 );/*</XHIST>*/
    xhist_buildtag[XHIST_VERSIONLENGTH - 1] = '\0';/*<XHIST>*/ _XH_ADD( 44706, 135 );/*</XHIST>*/
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
    xhist_logfd = fd;/*<XHIST>*/ _XH_ADD( 44706, 156 );/*</XHIST>*/
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
    long		l;
    short		s;

    BACKOUT_IF( xhist_logfd < 0, "invalid log device" );/*<XHIST>*/ _XH_ADD( 44706, 179 );/*</XHIST>*/

    /*
     *  write 4 bytes containing the number 4.  
     *  This establishes our byte order for the reader.
     *  Then write the size of the table and the index of the tail pointer.
     */

    l = (long) 4;/*<XHIST>*/ _XH_ADD( 44706, 187 );/*</XHIST>*/
    BACKOUT_IF(write(xhist_logfd, (char *) &l, sizeof(l)) < (ssize_t) sizeof(l), strerror(errno));/*<XHIST>*/ _XH_ADD( 44706, 188 );/*</XHIST>*/
    l = (long) (sizeof(xhist_tbl) / sizeof(xhist_tbl[0]));/*<XHIST>*/ _XH_ADD( 44706, 189 );/*</XHIST>*/
    BACKOUT_IF(write(xhist_logfd, (char *) &l, sizeof(l)) < (ssize_t) sizeof(l), strerror(errno));/*<XHIST>*/ _XH_ADD( 44706, 190 );/*</XHIST>*/
    BACKOUT_IF(write(xhist_logfd, (char *) &xhist_tail, sizeof(xhist_tail)) 
    	< (ssize_t) sizeof(xhist_tail), strerror(errno));/*<XHIST>*/ _XH_ADD( 44706, 192 );/*</XHIST>*/

    /*
     *  now write the length & name of the map file created during instrumentation
     *  and the length & version tag of the instrumented source
     */
    s = (short) strlen(xhist_mapfn);/*<XHIST>*/ _XH_ADD( 44706, 198 );/*</XHIST>*/
    BACKOUT_IF(write(xhist_logfd, (char *) &s, sizeof(s)) < (ssize_t) sizeof(s), strerror(errno));/*<XHIST>*/ _XH_ADD( 44706, 199 );/*</XHIST>*/
    BACKOUT_IF(write(xhist_logfd, (char *) &xhist_mapfn, s) < (ssize_t) s, strerror(errno));/*<XHIST>*/ _XH_ADD( 44706, 200 );/*</XHIST>*/

    s = (short) strlen(xhist_buildtag);/*<XHIST>*/ _XH_ADD( 44706, 202 );/*</XHIST>*/
    BACKOUT_IF(write(xhist_logfd, (char *) &s, sizeof(s)) < (ssize_t) sizeof(s), strerror(errno));/*<XHIST>*/ _XH_ADD( 44706, 203 );/*</XHIST>*/
    BACKOUT_IF(write(xhist_logfd, (char *) &xhist_buildtag, s) < (ssize_t) s, strerror(errno));/*<XHIST>*/ _XH_ADD( 44706, 204 );/*</XHIST>*/
    
    /*
     *  now write the entire table to the log device
     */
    
    BACKOUT_IF(write(xhist_logfd, (char *) &xhist_tbl, sizeof(xhist_tbl)) 
	< (ssize_t) sizeof(xhist_tbl), strerror(errno));/*<XHIST>*/ _XH_ADD( 44706, 211 );/*</XHIST>*/

backout:
    close(xhist_logfd);/*<XHIST>*/ _XH_ADD( 44706, 214 );/*</XHIST>*/
    fflush(stderr);/*<XHIST>*/ _XH_ADD( 44706, 215 );/*</XHIST>*/
}
