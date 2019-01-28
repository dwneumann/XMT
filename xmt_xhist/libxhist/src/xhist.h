/************************************************************************
*   $Version:$
*   Package	: xhist
*   Purpose	: 
*	Public interface to the xhist::xhist module.
*
*   Copyright (c) 2000	Neumann & Associates Information Systems Inc.
*  All Rights reserved.	legal.info@neumann-associates.com
*************************************************************************/

#ifndef __xhist_h
#define __xhist_h

#ifndef lint
static const char xhist_h_id[] = "@(#) xhist::xhist.h	$Version:$";
#endif

#define XHIST_SIZE		500	/* number of stmts to store in tbl */
#define XHIST_PATHLEN		32	/* fixed field length to write to log*/
#define XHIST_LOGFILE		"xhist.dat" /* default log file name */
#define _XH					\
{						\
    xhist_tbl[xhist_tail].xh_file = __FILE__;	\
    xhist_tbl[xhist_tail].xh_line = __LINE__;	\
    xhist_tail = ++xhist_tail % XHIST_SIZE;			\
}

typedef struct xhist
{
    char*	xh_file;	/* ptr to static string containing filename */
    short	xh_line;	/* max 65000 lines per file :-)	*/
} XH_REC;

extern XH_REC	xhist_tbl[ XHIST_SIZE ];
extern int	xhist_tail;

/* the functions of libxhist are not declared here,
 * because we do not want to force the IUT to link with libxhist.
 * Linking the IUT with libxhist is optional, and is used only if exporting
 * the circular buffer to a file descriptor during program exeecution.
extern  void	xhist_logdev(int fd);
extern  void	xhist_write();
*/

#endif /* __xhist_h	*/
