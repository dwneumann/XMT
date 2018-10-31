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

XH_REC	xhist_tbl[ XHIST_SIZE ]	= {{ NULL, 0 }};
int		xhist_tail		= 0;


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
    int		rc	= EXIT_FATAL;
    int		fd	= -1;
    char*	fn	= NULL;
    char	tmpbuf[XHIST_PATHLEN];
    int		intsize_written;
    int		count, i;
    char	swap	= FALSE;


    fn =( argc > 1 ? argv[argc - 1] : XHIST_LOGFILE );
    BACKOUT_IF( (fd = open( fn, O_RDONLY )) < 0, strerror(errno) );


    /*
     *  read the first sizeof(int) bytes from the file.
     *  These should be the size of the writers int.
     *  If We read it as our int size, no byte swapping is necessary.
     *  If we read it as the byteswapped equivalent of the writers int,
     *  we byteswap all remaining int fields read from the file.
     *  If we read a value other than one of those two, we error out.
     */

    BACKOUT_IF( read( fd, (char *) &intsize_written, sizeof( int ) ) 
    		< sizeof( int ), "unrecognized data format" );

    if ( intsize_written != sizeof( int ) )
    {
	BACKOUT_IF( BYTESWAP4( intsize_written ) != sizeof( int ),
			"unrecognized data format" );
	swap = TRUE;
    }


    /*
     *  now we read the tail index from the logfile and byteswap if appropriate
     */

    BACKOUT_IF( read( fd, (char *) &xhist_tail, sizeof( xhist_tail ) ) 
    	< sizeof( xhist_tail ), strerror(errno) );


    /*
     *  now we read XHIST_SIZE entries from the logfile into our xhist array,
     *  byteswapping line numbers if necessary
     */
    
    for ( i = 0; i < XHIST_SIZE; ++i )
    {
      BACKOUT_IF( read( fd, tmpbuf, sizeof( tmpbuf ) ) < sizeof( tmpbuf ),
             strerror(errno) );
      BACKOUT_IF( (xhist_tbl[i].xh_file = strdup(tmpbuf)) == NULL,
             strerror(ENOMEM) );

      BACKOUT_IF( read( fd, (char *) &xhist_tbl[i].xh_line, 
             sizeof( xhist_tbl[i].xh_line ) ) < 
             sizeof( xhist_tbl[i].xh_line ),
             strerror(errno) );

      if ( swap )
      {
          xhist_tbl[i].xh_line = BYTESWAP4( xhist_tbl[i].xh_line );
      }
    }


    /*
     *  The last instrunction executed is at xhist_tbl[xhist_tail],
     *  the previous instruction is at xhist_tail-1, then xhist_tail-2,
     *  all the way back to 0, then XHIST_SIZE back to xhist_tail+1.
     *  We want to list the instructions in order from oldest to latest,
     *  so we start at xhist_tail+1 and wrap around to xhist_tail.
     */

	for ( count=0, i = xhist_tail + 1; count < XHIST_SIZE; 
         ++count, i = (i+1) % XHIST_SIZE )
	{
       if (xhist_tbl[i].xh_line > 0)
       {
          printf( "%s:%d\n", xhist_tbl[i].xh_file, xhist_tbl[i].xh_line );
       }
	}

    rc = EXIT_OK;
 
backout:
    /* free all resources held.  Some OS's don't do this for us */
    (void) close(fd);
    for ( i = 0; i < XHIST_SIZE; ++i )
    {
        FREE( xhist_tbl[i].xh_file );
    }
    return( rc );
}
