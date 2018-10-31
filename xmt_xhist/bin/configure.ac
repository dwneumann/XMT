dnl Process this file with autoconf to produce a configure script.
AC_INIT(libxhist/src/xhist.c)
AM_INIT_AUTOMAKE(xmt_xhist, 1.0)
AM_CONFIG_HEADER(config.h)

dnl Checks for programs.
AM_PROG_LEX 
AC_PROG_CC

dnl Checks for libraries.
AC_PROG_RANLIB

dnl Checks for header files.
AC_HEADER_STDC
AC_CHECK_HEADERS(stdio.h errno.h string.h unistd.h fcntl.h stdlib.h)

dnl Checks for typedefs, structures, and compiler characteristics.
AC_C_CONST

dnl Checks for library functions.
AC_CHECK_FUNCS(strdup strerror)

AC_OUTPUT(Makefile libxhist/Makefile xhist_instrument/Makefile xhist_report/Makefile xhist_test/Makefile)
