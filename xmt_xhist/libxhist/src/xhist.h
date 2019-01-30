/************************************************************************
*   $Version: 5.2.2-22 [experimental] $
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
static const char xhist_h_id[] = "@(#) xhist::xhist.h	$Version: 5.2.2-22 [experimental] $";
#endif

#define XHIST_TBLSIZE		1000		/* number of stmts to store in tbl */
#define XHIST_MAPFNLENGTH	64		/* length of string storing map filename */
#define XHIST_VERSIONLENGTH	64		/* length of string storing build version */
#define XHIST_LOGFILE		"xhist.dat" 	/* default log file name */
#define _XH_ADD(filenum, linenum)		/* inline version of xhist_add() */	\
{											\
    xhist_tbl[xhist_tail] = (((unsigned short) filenum << 16) | (unsigned short) linenum);\
    xhist_tail = (unsigned short) ((xhist_tail+1) % XHIST_TBLSIZE);			\
}

extern unsigned long	xhist_tbl[ XHIST_TBLSIZE ];
extern unsigned long	xhist_tail;
extern char		xhist_mapfn[ XHIST_MAPFNLENGTH ];	/* filemap filename */
extern char		xhist_buildtag[ XHIST_VERSIONLENGTH ];	/* callers version string */

extern  void	xhist_logdev(int fd);
extern  void	xhist_mapfile(char *s);		/* store filename of mapfile to decode tbl */
extern  void	xhist_version(char *s);		/* store version tag of instrumented source */
extern  void	xhist_write();

#endif /* __xhist_h	*/
