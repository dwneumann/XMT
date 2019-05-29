/************************************************************************
*   $Version:$
*   Package	: xhist
*   Purpose : This file contains functions to maintain an in-memory trace
*   of execution history for multiple threads, and to output the trace to
*   an arbitrary file or socket upon program termination or upon receipt of
*   a signal. To output the trace upon receipt of a signal or upon exit the
*   program can install the xhist_write() function as a signal handler or
*   atexit handler. Use of fprintf(stderr,"...) is parameterized so it can
*   be replaced with whatever error handling infrastructure is available
*   on the target environment. 
*
*   Xhist (for "execution history") is a package which assists in the
*   diagnosis of intermittent, non-reproducible bugs as the software executes
*   in its target environment. Xhist is made up of an instrumentation program
*   "xhist_instrument", a postprocessing program "xhist_report", and runtime
*   libraries for various languages, which generate the trace files at runtime.
*
*   The instrumentation program "xhist_instrument" instruments the source
*   code of the software under test (currently C, C++ and Java are supported),
*   and produces modified source code that is then compiled and linked using
*   the same compiler, linker, and flags as the uninstrumented source.
*   The program $XMT/xmt_cm/bin/git_filter can be used to instrument and
*   clean entire source trees  at checkin/checkout of a git branch.
*
*   The instrumented software, when compiled and executed, records into a
*   circular buffer the filename, line number, and thread ID of each source
*   statement as it is executed. When the program misbehaves, the execution
*   history can be examined directly in memory (e.g. on an embedded target)
*   or the trace log can be exported to a file, socket, or serial device for
*   offline interpretation by the developer.
*
*   The postprocessing program "xhist_report" reads a previously written
*   trace log from file, and presents a human-readable formatted listing of
*   the last N source statements executed by each thread of the software
*   immediately prior to the log being written.  The program correctly
*   performs byteswapping if the architecture in which the software under
*   test executes is different than the environment in which the xhist_report
*   program executes.  The xhist_report program can also output the execution
*   history in a format that can be interpreted by vim to "replay" the sequence
*   statement by statement, as if steeping through with a debugger. Use of
*   the xhist_report program is optional.
*
*   Functions	:
*	boolean	xhist_init( char *logfile, char *mapfile, char *version )
*	void	xhist_deinit()
*	void	xhist_mapfile(char *s)
*	void	xhist_logfile(char *s)
*	void	xhist_logdev(int fd)
*	void	xhist_version(char *s)
*	void	xhist_write()
*	static void	xhist_write_to_descriptor( int fd )
*
*   Copyright (c) 1998	Neumann & Associates Information Systems Inc.
*   All Rights reserved.	legal.info@neumann-associates.com
************************************************************************/

/* xhist instrument FALSE */	// never instrument this file

#define __xhist_c
#ifndef lint
static const char xhist_c_id[] = "@(#) xhist::xhist.c	$Version:$";
#endif


/* pick up system configuration, whether using autoconf or xmt_build */
#if !defined(XMTBUILD)
#include <config.h> 
#endif

/* include stdio.h or make fprintf() and fflush() a no-op */
#if defined(HAVE_STDIO_H)
# include <stdio.h>
#else
# define fprintf(fd, fmt, msg) ;	// no-op
# define fflush(fd) ;			// no-op
#endif

/* include errno.h & string.h or make strerror() a generic message */
#if defined(HAVE_ERRNO_H)
# if defined(HAVE_STRING_H)
#  include <errno.h>
#  include <string.h>
# endif
#else
# define strerror(errno) "system error"
#endif

/* include unistd.h or declare close() & write() implicitly */
#if defined(HAVE_UNISTD_H)
# include <unistd.h>
# include <fcntl.h>
# include <stdlib.h>
#endif

#include "assert.h"

#define NULL ((void *)0)

/* this is how we do try-catch blocks in C */
#define BACKOUT_IF(ex, msg)	\
	if (ex) { fprintf(stderr, "%s\n", msg); goto backout; }

#include "xhist.h"
static void	xhist_write_to_descriptor(int);

#if defined( XHIST_MULTI_THREADED ) //  pull in stuff we need for multi-threaded operation
# include <sys/syscall.h>
# include <pthread.h>
#endif 


/* instantiate one global xhist table, a mutex and a thread-local table index */
xh_t		xh = { 0 };

#if defined( XHIST_MULTI_THREADED )
    __thread short		xh_idx	= -1;	// per-thread index into other tables
    static pthread_mutex_t	xh_mutex	= PTHREAD_MUTEX_INITIALIZER;	
#else
    short	xh_idx = 0;
#endif


/************************************************************************
*   Synopsis:
*	boolean	xhist_init( char *logfile, char *mapfile, char *version )
*
*   Purpose:
*       initializes xhist execution history logging for the current
*       thread. This function must be called near the beginning of each
*       thread that is to have its execution history logged.    
*	This function is concurrency-safe.
*       It is safe to call instrumented functions from threads that have
*       not called xhist_init().  Statement instrumentation in uninitialized
*       threads evaluates to a no-op.
* 
*   Parameters: 
*	char	*logfile	: path to logfile to write to
*	char	*mapfile	: path to mapfile generated during instrumentation
*	char	*version 	: static build version identification string
* 
*   Values Returned: 
*	TRUE	:  initialization was successful for this thread.
*	FALSE	:  Execution for this thread will not be logged.
* 
***********************************************************************/
boolean xhist_init( char *logfile, char *mapfile, char *version )
{
    int		i, thr;
    boolean	rc = FALSE;

    /*
     * initialize a history table for this thread.
     * This requires concurrency-safe access to xhist_thread_ids[] 
     * so we lock a mutex during table access if needed.
     */
    
#if defined( XHIST_MULTI_THREADED )
    thr = (int) syscall(SYS_gettid);
    pthread_mutex_lock(&xh_mutex);
#endif

    for (i=0; i < XHIST_MAX_THREADS; i++)
    {
	if ( xh.thread_ids[i] == 0 )	// find the first unused index
	{
	    break;
	}
    }
    if ( i >= XHIST_MAX_THREADS )
    {
	assert(FALSE);		// we've called xhist_init too many times.
	BACKOUT_IF(TRUE, "XHIST_MAX_THREADS exceeded");
    }

    xh.thread_ids[i] = thr;	// claim the first unused column for this thread
    xh_idx = i;			// save the column index 

    xhist_mapfile(mapfile);	// save the mapfile path 
    xhist_logfile(logfile);	// save the logfile path 
    xhist_version(version);	// save the version string
    atexit(xhist_write);	// install handler to write table at program exit
    rc = TRUE; 			// successful initialization

    /* this is how we do try-catch blocks in C */
    backout:
    // free the mutex lock
    pthread_mutex_unlock(&xh_mutex);
    return(rc); 
}


/************************************************************************
*   Synopsis:
*	void	xhist_deinit()
*
*   Purpose:
* 	deinitializes Xhist for the current thread 
* 	(called during cleanup of crashed thread, before restarting a new thread).
* 
*   Parameters: 
* 
*   Values Returned: 
*	none
* 
***********************************************************************/
void xhist_deinit() 
{
    xh.thread_ids[xh_idx] = 0;		// release this column index for reuse
    xh_idx = -1;
}


/************************************************************************
*   Synopsis:
*	void	xhist_mapfile(char *s)
*
*   Purpose:
*	Stores the name of the mapfile needed to decode the hashed names in the table.
* 
*   Parameters: 
*	char	*s : xmap filename generated during instrumentation
* 
*   Values Returned: 
*	none	 
* 
***********************************************************************/
void	xhist_mapfile(char *s)
{
    memset( (void *) xh.mapfn, (int) 0, (size_t) XHIST_MAX_PATHLEN );
    (void) strncpy( xh.mapfn, s, (size_t) XHIST_MAX_PATHLEN );
    xh.mapfn[XHIST_MAX_PATHLEN - 1] = '\0';
}

/************************************************************************
*   Synopsis:
*	void	xhist_logfile(char *s)
*
*   Purpose:
*       Stores the path to the file to write the history buffer to. 
* 
*   Parameters: 
*	char	*s : path to create & write output to
* 
*   Values Returned: 
*	none	 
* 
***********************************************************************/
void	xhist_logfile(char *s)
{
    memset( (void *) xh.logfn, (int) 0, (size_t) XHIST_MAX_PATHLEN );
    (void) strncpy( xh.logfn, s, (size_t) XHIST_MAX_PATHLEN );
    xh.logfn[XHIST_MAX_PATHLEN - 1] = '\0';
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
    xh.logfd = fd;
}

/************************************************************************
*   Synopsis:
*	void	xhist_version(char *s)
*
*   Purpose:
*	Stores the build tag of the instrumented source from which the table was geenerated.
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
    memset( (void *) xh.buildtag, (int) 0, (size_t) XHIST_VERSIONLEN );
    strncpy( xh.buildtag, s, (size_t) XHIST_VERSIONLEN );
    xh.buildtag[XHIST_VERSIONLEN - 1] = '\0';
}

/************************************************************************
*   Synopsis:
*	void	xhist_write()
*
*   Purpose:
*	Writes in-memory table to the log device specified via xhist_logfile() or xhist_logdev().
*       NOTE: Sucessive calls to xhist_write() when xhist_logfile() has been
*       specified overwrites the file with each invokation.  Successive calls
*       to xhist_write() when a file descriptor (eg a socket) has been specified 
*	via xhist_logdev() does not / cannot overwrite previous writes.
*	If xhist_logdev() specifies a descriptor to a file on a filesystem and you invoke
*	xhist_write() successively, you will concatentate output to the file, resulting
*	in an invalid file.
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
    int fd;

    /*
     * if a pre-existing descriptor has been specified, write to that.
     * Otherwise open the logfile, write to that, then close it
     * so that subsequent invokations will overwrite the file.
     */

    if ( xh.logfd > 0 )
    {
	xhist_write_to_descriptor(xh.logfd);
    }
    else
    {
	BACKOUT_IF((fd = open(xh.logfn, O_RDWR|O_CREAT, 
		S_IRUSR|S_IWUSR|S_IRGRP|S_IWGRP)) < 0,  "error opening logfile");
	xhist_write_to_descriptor(fd);
	close(fd);
    }

    /* this is how we do try-catch blocks in C */
    backout:
    fd = -1;
}

/************************************************************************
*   Synopsis:
*	static void	xhist_write_to_descriptor( int fd )
*
*   Purpose:
*	write the history table to the open descriptor <fd>
*	Also see xhist_write().
* 
*   Parameters: 
*	int	fd 	: open file descriptor to write to
* 
*   Values Returned: 
*	none	
* 
***********************************************************************/
static void	xhist_write_to_descriptor( int fd )
{
    long	l;
    short	s;


    BACKOUT_IF( fd < 0, "invalid log device" );

    /*
     *  write 4 bytes containing the magic number 5.  
     *  This establishes the version of binary file being written
     *  and our byte order for the reader.
     *  Then write the depth of the history per thread.
     */

    l = (long) 5;
    BACKOUT_IF(write(fd, (char *) &l, sizeof(l)) < sizeof(l), strerror(errno));

    l = (long) XHIST_MAX_HISTORY;
    BACKOUT_IF(write(fd, (char *) &l, sizeof(l)) < sizeof(l), strerror(errno));


    /*
     *  write the 2-byte length & name of the map file created during instrumentation
     *  and   the 2-byte length & build tag of the instrumented source
     */
    s = (short) strlen(xh.mapfn);
    BACKOUT_IF(write(fd, (char *) &s, sizeof(s)) < sizeof(s), strerror(errno));
    BACKOUT_IF(write(fd, (char *) &xh.mapfn, s) < s, strerror(errno));

    s = (short) strlen(xh.buildtag);
    BACKOUT_IF(write(fd, (char *) &s, sizeof(s)) < sizeof(s), strerror(errno));
    BACKOUT_IF(write(fd, (char *) &xh.buildtag, s) < s, strerror(errno));
    
    /*
     *  now write the history table for all threads.
     */
    
    for (s = 0; s < XHIST_MAX_THREADS; ++s)
    {
	if (xh.thread_ids[s] > 0)	//  only write non-empty threads
	{
	    /* write 4-byte thread ID and 4-byte index of tail entry for this thread */
	    BACKOUT_IF(write(fd, (char *) &xh.thread_ids[s], sizeof(l)) 
		    < sizeof(l), strerror(errno));
	    BACKOUT_IF(write(fd, (char *) &xh.tails[s], sizeof(l)) 
		    < sizeof(l), strerror(errno));

	    /*  the table is stored in row-major order so write the entire row at once. */
	    BACKOUT_IF(write(fd, (char *) xh.tbl[s], sizeof(xh.tbl[s])) 
		< sizeof(xh.tbl[s]), strerror(errno));
	}
    }

    /* this is how we do try-catch blocks in C */
    backout:
    fd = -1;
}
