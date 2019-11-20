#************************************************************************
#*   $Version:$
#*   Package	: xmt_build
#*   Synopsis	: included by $(XMTBUILD)/proto/Makefile.top
#*   Purpose	: 
#*              This Makefile segment adds language support to
#*              $(XMTBUILD)/proto/Makefile.top
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


#   := assignements are evaluated during lexical scan;
#    = assignments are recursively expanded during rule parsing
srcs.java	:= $(wildcard $(SRCDIR)/$(JAVA_PKGROOT)/*.java)
hdrs.java	:= 
#srcs.java	:= $(shell find $(SRCDIR)/ -type f -name '*.java')
objs.java	:= $(patsubst $(SRCDIR)/$(JAVA_PKGROOT)/%.java,$(JAVA_PKGROOT)/%.class,$(srcs.java))
docs.java	:= $(patsubst $(SRCDIR)/$(JAVA_PKGROOT)/%.java,$(DOCDIR)/%.html,$(srcs.java))
lnts.java	:= 

#**********************************************************************
# This is the place to define default flags that are common to ALL 
# supported architectures for THIS language.
#**********************************************************************
CFLAGS.java	+= -g -d $(OBJDIR) 
LDFLAGS.java	= 
ARFLAGS.java	= cf 
LINTFLAGS.java	= 
DOCFLAGS.java	= 

## Define recipes in $(XMTBUILD)/proto/lang/$(LANGUAGE)/$(ARCH)
## after variables are further defined there 
