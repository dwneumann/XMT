#************************************************************************
#*   $Version:$
#*   Package	: xmt_build
#*   Synopsis	: included by $(XMTBUILD)/proto/lang/<language>/generic.inc
#*   Purpose	: 
#*              This Makefile segment adds architecture support to
#*              $(XMTBUILD)/proto/lang/<language>/generic.inc
#*              It is intended to be included by that file only.
#*
#*   To add support for a new target architecture,  clone any existing
#*   <architecture>.inc file & alter program paths & flags appropriately.
#*   Remember to also update $(XMTBUILD)/proto/cshrc  to add the new
#*   architecture to XMTBUILD_SUPP_ARCHS.
#*
#*  Copyright (c) 1998	Neumann & Associates Information Systems Inc.
#*  			legal.info@neumann-associates.com
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
COMPILE.$l.SunOS-sparc	:= /usr/local/bin/g++
LD.$l.SunOS-sparc	:= $(COMPILE.$l.SunOS-sparc)
AR.$l.SunOS-sparc	:= $(COMPILE.$l.SunOS-sparc)
LINT.$l.SunOS-sparc	:= echo /usr/ucb/lint not installed
DOC.$l.SunOS-sparc	:= $(XMTBUILD)/bin/srcdoc 

#**********************************************************************
# This is the place to define default flags that are specific to THIS 
# platform and THIS language.
#**********************************************************************
CFLAGS.$l.SunOS-sparc	:= -Wall -fpic
LDFLAGS.$l.SunOS-sparc	:= -Wall 
ARFLAGS.$l.SunOS-sparc	:= -Wall -shared
LINTFLAGS.$l.SunOS-sparc	 = $(CFLAGS.cc.SunOS-sparc)
DOCFLAGS.$l.SunOS-sparc	:= 
LIB_PFX.$l.SunOS-sparc	:= lib
LIB_SFX.$l.SunOS-sparc	:= .so
EXE_PFX.$l.SunOS-sparc	:= 
EXE_SFX.$l.SunOS-sparc	:= 
