/************************************************************************
*   $Version:$
*   Package	: xhist
*   Purpose	: 
*	Public interface to the xhist::xhist module.
*
*   Copyright (c) 2000	Neumann & Associates Information Systems Inc.
*  All Rights reserved.	legal.info@neumann-associates.com
*************************************************************************/

/* xhist instrument FALSE */			// never instrument this file

#ifndef __xhist_h
#define __xhist_h

#ifndef lint
static const char xhist_h_id[] = "@(#) xhist::xhist.h	$Version:$";
#endif

typedef char boolean;
#ifndef TRUE
# define TRUE 1
# define FALSE 0
#endif

#ifndef ASSERT
# define ASSERT(x)
#endif	

#define XHIST_MAX_HISTORY	1000		// max history depth per thread
#define XHIST_MAX_THREADS	20		// max number of threads to keep history 
#define XHIST_MAPFNLENGTH	256		// length of string storing map filename
#define XHIST_VERSIONLENGTH	64		// length of string storing build version

# if (XHIST_MAX_THREADS > 1)  		
# define XHIST_MULTI_THREADED	
#endif 

/* xhist global struct */
typedef struct  
{
    long	tbl[ XHIST_MAX_THREADS ][ XHIST_MAX_HISTORY ];	// N trace stmts x M threads
    long	thread_ids[ XHIST_MAX_THREADS ];		// thread to column mapping
    long	tails[ XHIST_MAX_THREADS ];			// last stmt indexes
    char	mapfn[ XHIST_MAPFNLENGTH ];			// filemap filename
    char	buildtag[ XHIST_VERSIONLENGTH ];		// callers version string
    int  	logfd;						// file descriptor
} xh_t;

/*
 * xhist_add is defined as a macro which appends (filenum, linenum) 
 * to the execution history buffer for the current thread.
 * It is thread-safe, constant-time with no function call overhead.
 */
#define xhist_add(f, l)								\
{										\
    xh.tbl[xh_idx][xh.tails[xh_idx]] = (((short) f << 16) | (short) l);		\
    xh.tails[xh_idx] = (long) ((xh.tails[xh_idx]+1) % XHIST_MAX_HISTORY);	\
}

extern xh_t		xh;			// xhist table instance
extern __thread short	xh_idx;			// per-thread index into other tables

extern boolean	xhist_init( char *logfile, char *mapfile, char *version );
extern void	xhist_deinit();
extern void	xhist_mapfile(char *s);
extern void	xhist_version(char *s);
extern void	xhist_logdev(int fd);
extern void	xhist_write();

#endif /* __xhist_h	*/
