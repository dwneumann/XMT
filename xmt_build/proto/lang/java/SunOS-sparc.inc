#************************************************************************
#*   $Version:$
#*   Package	: xmt_build
#*   Synopsis	: included by $(XMTBUILD)/proto/lang/<language>/generic.inc
#*   Purpose	: 
#*			  This Makefile segment adds architecture support to
#*			  $(XMTBUILD)/proto/lang/<language>/generic.inc
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

arch = SunOS-sparc

#**********************************************************************
# define program paths...
#**********************************************************************
DOCER.$(lang).$(arch)	= $(DOCER.$(lang))
LINTER.$(lang).$(arch)	= $(LINTER.$(lang))
COMPILER.$(lang).$(arch)= $(COMPILER.$(lang))
LINKER.$(lang).$(arch)	= $(LINKER.$(lang))
ARCHIVER.$(lang).$(arch)= $(ARCHIVER.$(lang))
OBJCOPY.$(lang).$(arch)	= $(OBJCOPY.$(lang))

#**********************************************************************
# This is the place to define flags that are specific to THIS language
# when compiled for THIS architecture.
#**********************************************************************
CFLAGS.$(lang).$(arch)		+= 
LDFLAGS.$(lang).$(arch)		+= 
ARFLAGS.$(lang).$(arch)		+= 
LINTFLAGS.$(lang).$(arch)	+= 
DOCFLAGS.$(lang).$(arch)	+= 
LIB_PFX.$(lang).$(arch)		= 
LIB_SFX.$(lang).$(arch)		= .jar
EXE_PFX.$(lang).$(arch)		= 
EXE_SFX.$(lang).$(arch)		= 

$(JAVA_PKGROOT)/%.class: $(SRCDIR)/$(JAVA_PKGROOT)/%.$(lang)
	@mkdir -p $(@D)
	@mkdir -p $(OBJDIR)/$(JAVA_PKGROOT);
	@echo	$(CFLAGS) $(CFLAGS.$(lang)) $(CFLAGS.$(lang).$(arch)) > $(OBJDIR)/$@.cflags ;
	$(COMPILER.$(lang).$(arch))	@$(OBJDIR)/$@.cflags $<

.PHONY: docs.$(lang).$(arch) 
docs.$(lang).$(arch) :
	$(DOCER.$(LANGUAGE).$(ARCH))	\
		$(DOCFLAGS) $(DOCFLAGS.$(LANGUAGE)) $(DOCFLAGS.$(LANGUAGE).$(ARCH))

lib.$(lang).$(arch):	$(TGTDIR)/$(LIB_NM)
exe.$(lang).$(arch):	$(TGTDIR)/$(LIB_NM)
$(TGTDIR)/$(LIB_NM): $(objs.$(lang)) 
	@mkdir -p $(@D)
	(cd $(OBJDIR);  \
	echo $(ARFLAGS) $(ARFLAGS.$(lang)) $(ARFLAGS.$(lang).$(arch)) > $(LIB_NM).arflags;\
	$(ARCHIVE.$(lang).$(arch)) @$(LIB_NM).arflags $(LIB_NM) *.class;)
	-/bin/mv $(OBJDIR)/$(LIB_NM) $(TGTDIR)/$(LIB_NM)
