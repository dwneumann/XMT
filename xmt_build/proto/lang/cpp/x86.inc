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
COMPILE.cpp.$(ARCH)	= g++
LD.cpp.$(ARCH)		= $(COMPILE.cpp.$(ARCH))
AR.cpp.$(ARCH)		= ar
LINT.cpp.$(ARCH)	= echo /usr/ucb/lint not installed
DOC.cpp.$(ARCH)		= $(XMTBUILD)/bin/srcdoc 
#**********************************************************************
# This is the place to define default flags that are specific to THIS 
# platform and THIS language.
#**********************************************************************
CFLAGS.cpp.$(ARCH)	= -Wall -Wno-attributes -Wno-unused-function -Wno-unused-const-variable -isystem /usr/include/x86_64-linux-gnu
LDFLAGS.cpp.$(ARCH)	= $(CFLAGS.cpp.$(ARCH))
ARFLAGS.cpp.$(ARCH)	= -r
LINTFLAGS.cpp.$(ARCH)	= $(CFLAGS.cpp.$(ARCH))
DOCFLAGS.cpp.$(ARCH)	= 
LIB_PFX.cpp.$(ARCH)	= lib
LIB_SFX.cpp.$(ARCH)	= .a
EXE_PFX.cpp.$(ARCH)	= 
EXE_SFX.cpp.$(ARCH)	= 

$(OBJDIR)/%.o	: %.S
	@mkdir -p $(@D)
	@echo  $(CFLAGS) $(CFLAGS.cpp) $(CFLAGS.cpp.$(ARCH)) > $@.cflags ;
	$(COMPILE.cpp.$(ARCH)) @$@.cflags $<

$(OBJDIR)/%.o	: %.s
	@mkdir -p $(@D)
	@echo  $(CFLAGS) $(CFLAGS.cpp) $(CFLAGS.cpp.$(ARCH)) > $@.cflags ;
	$(COMPILE.cpp.$(ARCH)) @$@.cflags $<

$(OBJDIR)/%.o	: %.cpp
	@mkdir -p $(@D)
	@echo  $(CFLAGS) $(CFLAGS.cpp) $(CFLAGS.cpp.$(ARCH)) > $@.cflags ;
	$(COMPILE.cpp.$(ARCH)) @$@.cflags $<

$(OBJDIR)/%.i	: /%.cpp
	@mkdir -p $(@D)
	@echo  $(CFLAGS) $(CFLAGS.cpp) $(CFLAGS.cpp.$(ARCH)) -E > $@.cflags ;
	$(COMPILE.cpp.$(ARCH)) @$@.cflags -E $<

$(OBJDIR)/%.ln	: %.cpp
	@mkdir -p $(@D)
	@echo  $(LINTFLAGS) $(LINTFLAGS.cpp) $(LINTFLAGS.cpp.$(ARCH)) > $@.lintflags ;
	$(LINT.cpp.$(ARCH)) @$@.lintflags $<

$(DOCDIR)/%.html: $(SRCDIR)/%.cpp
	@mkdir -p $(@D)
	@echo  $(DOCFLAGS) $(DOCFLAGS.cpp) $(DOCFLAGS.cpp.$(ARCH)) > $@.docflags ;
	$(DOC.cpp.$(ARCH)) @$@.docflags $<

.lib.$(LANGUAGE):	$(TGTDIR)/$(LIB_NM)
$(LIB_NM): $(TGTDIR)/$(LIB_NM)
$(TGTDIR)/$(LIB_NM): $(objs.$(LANGUAGE)) $(EXTRA_OBJS)
	@mkdir -p $(@D)
	@echo 	$(ARFLAGS) $(ARFLAGS.$(LANGUAGE)) $(ARFLAGS.$(LANGUAGE).$(ARCH)) > $@.arflags;
	$(AR.$(LANGUAGE).$(ARCH)) @$@.arflags $@ $^ 	

.exe.$(LANGUAGE):	$(TGTDIR)/$(EXE_NM)
$(EXE_NM): $(TGTDIR)/$(EXE_NM)
$(TGTDIR)/$(EXE_NM): $(objs.$(LANGUAGE)) $(EXTRA_OBJS) 
	@mkdir -p $(@D)
	@echo $(LDFLAGS) $(LDFLAGS.$(LANGUAGE)) $(LDFLAGS.$(LANGUAGE).$(ARCH)) > $@.ldflags;
	$(LD.$(LANGUAGE).$(ARCH)) @$@.ldflags $^ \
	    $(LIBS) $(LIBS.$(LANGUAGE)) $(LIBS.$(LANGUAGE).$(ARCH)) 


