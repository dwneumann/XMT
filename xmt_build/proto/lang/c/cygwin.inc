#************************************************************************
#*   $Version:$
#*   Package	: xmt_build
#*   Synopsis	: included by $(XMTBUILD)/proto/lang/<language>/generic.inc
#*   Purpose	: 
#*              This Makefile segment adds architecture support to
#*              $(XMTBUILD)/proto/lang/<language>/generic.inc
#*
#*   To add support for a new target architecture,  clone any existing
#*   <architecture>.inc file & alter program paths & flags appropriately.
#*   Remember to also update $(XMTBUILD)/proto/cshrc  to add the new
#*   architecture to XMTBUILD_SUPP_ARCHS.
#*
#*  Copyright (c) 2017	Visionary Research Inc.
#*  			info@visionary-research.com
#*  Licensed under the Apache License, Version 2.0 (the "License");
#*  you may not use this file except in compliance with the License.
#*  You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
#*  
#*  Unless required by applicable law or agreed to in writing, software
#*  distributed under the License is distributed on an "AS IS" BASIS,
#*  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#*  See the License for the specific language governing permissions and
#*  limitations under the License. 
#************************************************************************

#**********************************************************************
# define program paths...
#**********************************************************************
COMPILE.c.cygwin	:= /usr/bin/gcc
LD.c.cygwin		:= /usr/bin/gcc
AR.c.cygwin		:= /usr/bin/ar
DOC.c.cygwin		:= $(XMTBUILD)/bin/srcdoc 
LINT.c.cygwin		:= echo lint not installed
LIB_PFX.c.cygwin	:= lib
LIB_SFX.c.cygwin	:= .a
EXE_PFX.c.cygwin	:= 
EXE_SFX.c.cygwin	:= 

#**********************************************************************
# This is the place to define default flags that are specific to THIS 
# platform and THIS language.
#**********************************************************************
CFLAGS.c.cygwin += -Wall -Wno-unused-const-variable
LDFLAGS.c.cygwin	+= $(CFLAGS.c.cygwin) 
ARFLAGS.c.cygwin	+= -r
LINTFLAGS.c.cygwin	+= $(CFLAGS.c.cygwin)
DOCFLAGS.c.cygwin	+= 

