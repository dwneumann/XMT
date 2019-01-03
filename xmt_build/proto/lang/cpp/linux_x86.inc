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
COMPILE.cpp.linux_x86	:= g++
LD.cpp.linux_x86	:= $(COMPILE.cpp.linux_x86)
AR.cpp.linux_x86	:= ar
LINT.cpp.linux_x86	:= echo /usr/ucb/lint not installed
DOC.cpp.linux_x86	:= $(XMTBUILD)/bin/srcdoc 
#**********************************************************************
# This is the place to define default flags that are specific to THIS 
# platform and THIS language.
#**********************************************************************
CFLAGS.cpp.linux_x86	= -Wall -m32 
LDFLAGS.cpp.linux_x86	= -Wall  -m32
ARFLAGS.cpp.linux_x86	= -r
LINTFLAGS.cpp.linux_x86	= $(CFLAGS.cpp.linux_x86)
DOCFLAGS.cpp.linux_x86	= 
LIB_PFX.cpp.linux_x86	= lib
LIB_SFX.cpp.linux_x86	= .a
EXE_PFX.cpp.linux_x86	= 
EXE_SFX.cpp.linux_x86	= 
