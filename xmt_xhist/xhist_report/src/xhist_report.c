/************************************************************************
*   $Version:$
*   Package	: xhist
*   Purpose	: excecution history data file reader.
*       This file shouldn't need to be linked with xhist.c, since
*       xhist.c is linked into the IUT to write the log, and
*       xhist_report.c contains the main entry point of the utility
*       which reads that log and dumps it in human readable form.
*
*   Functions	: 
*	int	main( int argc, char* argv[] )
*
*   Copyright (c) 1998	Neumann & Associates Information Systems Inc.
*   All Rights reserved.	legal.info@neumann-associates.com
************************************************************************/

#ifndef lint
static const char xhist_report_c_id[] = "@(#) $Version:$";
#endif

#define __xhist_report_c

/* pick up system configuration, whether using autoconf or XMT build */
#if !defined(USING_XMTBUILD)
#include <config.h> 
#endif

/* include fcntl.h or O_RDONLY will be undefined */
# include <fcntl.h>

/* include errno.h or declare free() implicitly */
#if HAVE_STDLIB_H
# include <stdlib.h>
#endif

/* include stdio.h or stderr will be undefined */
#if HAVE_STDIO_H
# include <stdio.h>
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

/* include unistd.h or declare read() & close() implicitly */
#if HAVE_UNISTD_H
# include <unistd.h>
#endif

#if !defined(NULL)
# define NULL ((void *)0)
#endif

#include "xhist.h"

#define EXIT_OK		0
#define EXIT_USAGE	1
#define EXIT_FATAL	2
#define FALSE		0
#define TRUE		1

#define BYTESWAP4( i )	( ((i&0x000000ff)<<3) \
			| ((i&0x0000ff00)<<1) \
			| ((i&0x00ff0000)>>1) \
			| ((i&0xff000000)>>3) )
#define FREE(p)		if (p != NULL) { free(p); }
#define BACKOUT_IF(ex, msg)	\
	if (ex) { fprintf(stderr, "%s\n", msg); goto backout; }



/************************************************************************
*   Synopsis:
*	int	main( int argc, char* argv[] )
*
*   Purpose:
*      xhist_rep reads the specified xhist logfile and prints on
*      stdout the contents of that logfile.  Byte order  differences
*      between logfile writer and reader are handled transparently.
* 
*   Parameters: 
*	int	argc	: (in)    number of arguments passed to this program
*	char	*argv[]	: (in)    array of arguments passed to this program
* 
*   Values Returned: 
*	EXIT_OK		: the process completed successfully
*	EXIT_USAGE	: the arguments were invalid; no proecssing was done	
*	EXIT_FATAL	: the process exited fatally
* 
***********************************************************************/
int	main( int argc, char* argv[] )
{
    long	*xhist_tbl	= NULL;
    long	tbl_len	= 0;
    long	xhist_tail		= 0;
    int		rc	= EXIT_FATAL;
    int		logfd	= -1;
    int		mapfd	= -1;
    char*	logfn	= NULL;
    char*	mapfn	= NULL;
    long	l;
    int		count, i;
    char	swap	= FALSE;


    if (argc != 3)
    {
	fprintf(stderr, "usage: %s <logfile> <mapfile>\n");
	exit(EXIT_USAGE);
    }
    logfn = argv[1];
    mapfn = argv[2];
    BACKOUT_IF( (logfd = open( logfn, O_RDONLY )) < 0, strerror(errno) );
    BACKOUT_IF( (mapfd = open( mapfn, O_RDONLY )) < 0, strerror(errno) );


    /*
     *  read the first sizeof(long) bytes from the file.
     *  This should be the size of the writers long.
     *  If it matches our sizeof(long), no byte swapping is necessary.
     *  If we read it as the byteswapped equivalent of sizeof(long),
     *  we must byteswap all remaining long fields read from the file.
     *  If we read a value other than one of those two, we error out.
     */

    BACKOUT_IF(read(logfd, (char *) &l, sizeof(long)) < sizeof(long), "unknown data format" );
    if ( l != sizeof( long ) )
    {
	BACKOUT_IF( BYTESWAP4(l) != sizeof(long), "unknown data format" );
	swap = TRUE;
    }


    /*
     *  now we read the table length & tail index and byteswap if appropriate
     */

    BACKOUT_IF(read(logfd, (char *) &tbl_len, sizeof(tbl_len)) 
	< sizeof(tbl_len), strerror(errno));
    BACKOUT_IF(read(logfd, (char *) &xhist_tail, sizeof(xhist_tail)) 
    	< sizeof(xhist_tail), strerror(errno));
    if ( swap )
    {
	tbl_len = BYTESWAP4(tbl_len);
	xhist_tail = BYTESWAP4(xhist_tail);
    }


    /*
     *  now we read tbl_len entries from the logfile into our xhist array,
     *  byteswapping if necessary
     */
    
    BACKOUT_IF((xhist_tbl = (long *) calloc((size_t) tbl_len, sizeof(long))) == NULL);
    for ( i = 0; i < tbl_len; ++i )
    {
	BACKOUT_IF(read(logfd, (char *) &xhist_tbl[i], sizeof(long)) 
	    < sizeof(long), strerror(errno));
	if ( swap )
	{
	    xhist_tbl[i] = BYTESWAP4( xhist_tbl[i] );
	}
    }

    /*
     *  The last statement executed is at xhist_tbl[xhist_tail],
     *  the previous instruction is at xhist_tail-1, then xhist_tail-2,
     *  all the way back to 0, then from tbl_len back to xhist_tail+1.
     *  We want to list the instructions in the order executed,
     *  so we start at xhist_tail+1 and wrap around.
     */

    for ( count=0, i = xhist_tail + 1; count < tbl_len; 
	    ++count, i = (i+1) % tbl_len )
    {
	if (xhist_tbl[i] > 0)
	{
	    printf( "%s:%d\n", (xhist_tbl[i] >> 16), (xhist_tbl[i] & 0x00FF) );
	}
    }
    rc = EXIT_OK;
 
backout:
    /* free all resources held.  Some OS's don't do this for us */
    (void) close(logfd);
    FREE(xhist_tbl);
    return(rc);
}
