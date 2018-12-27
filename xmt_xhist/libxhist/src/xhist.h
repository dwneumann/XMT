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

#define XHIST_SIZE		1000		/* number of stmts to store in tbl */
#define XHIST_LOGFILE		"xhist.dat" 	/* default log file name */
#define _XHIST(filenum, linenum)			\
{							\
    xhist_tbl[xhist_tail] = ((filenum << 16) | linenum);\
    xhist_tail = ++xhist_tail % XHIST_SIZE;		\
}

extern long	xhist_tbl[ XHIST_SIZE ];
extern short	xhist_tail;

/* the functions of libxhist are not declared here,
 * because we do not want to force the IUT to link with libxhist.
 * Linking the IUT with libxhist is necessary only if exporting
 * the circular buffer to a file descriptor during program execution.
extern  void	xhist_logdev(int fd);
extern  void	xhist_write();
*/

#endif /* __xhist_h	*/

