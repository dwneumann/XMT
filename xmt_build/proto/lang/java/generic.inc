#************************************************************************
#*   Package	: xmt_build
#*   Synopsis	: included by $(XMTBUILD)/proto/Makefile.top
#*   Purpose	: 
#*			  This Makefile segment adds language support to
#*			  $(XMTBUILD)/proto/Makefile.top
#*			  It is intended to be included by that file only.
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

#   := assignements are evaluated during lexical scan;
#	= assignments are recursively expanded during rule parsing
override lang	:= java

srcs.$(lang)	= $(wildcard $(SRCDIR)/$(JAVA_PKGROOT)/*.$(lang))
hdrs.$(lang)	= 
objs.$(lang)	= $(patsubst $(SRCDIR)/$(JAVA_PKGROOT)/%.$(lang),$(JAVA_PKGROOT)/%.class,$(srcs.$(lang)))
docs.$(lang)	= $(patsubst $(SRCDIR)/$(JAVA_PKGROOT)/%.$(lang),$(DOCDIR)/%.html,$(srcs.$(lang)))
lnts.$(lang)	= 

#**********************************************************************
# This is the place to define default flags that are common to ALL 
# supported architectures for THIS language.
#**********************************************************************
DOCER.$(lang)		= $(DOCER)
LINTER.$(lang)		= 
COMPILER.$(lang)	= /usr/bin/javac
LINKER.$(lang)		= /bin/true
ARCHIVER.$(lang)	= /usr/bin/jar
OBJCOPY.$(lang)		= echo no objcopy for $(lang)
CFLAGS.$(lang)		= -g -d $(OBJDIR) 
LDFLAGS.$(lang)		= 
ARFLAGS.$(lang)		= cf 
LINTFLAGS.$(lang)	= 
DOCFLAGS.$(lang)	= $(PROJECT)/proto/Doxyfile

## Define recipes in $(XMTBUILD)/proto/lang/$(LANGUAGE)/$(ARCH)
