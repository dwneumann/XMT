#************************************************************************
#*   $Version:$
#*   Package	: xmt_build
#*   Synopsis	: included by $(XMTBUILD)/proto/lang/cpp/generic.inc
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
COMPILE.cpp.SunOS-sparc	:= /usr/local/bin/g++
LD.cpp.SunOS-sparc	:= $(COMPILE.cpp.SunOS-sparc)
AR.cpp.SunOS-sparc	:= $(COMPILE.cpp.SunOS-sparc)
LINT.cpp.SunOS-sparc	:= echo /usr/ucb/lint not installed
DOC.cpp.SunOS-sparc	:= $(XMTBUILD)/bin/srcdoc 

#**********************************************************************
# This is the place to define default flags that are specific to THIS 
# platform and THIS language.
#**********************************************************************
CFLAGS.cpp.SunOS-sparc	:= -Wall -Wno-attributes -Wno-unused-function -Wno-unused-const-variable -fpic
LDFLAGS.cpp.SunOS-sparc	:= -Wall -Wno-attributes -Wno-unused-function -Wno-unused-const-variable 
ARFLAGS.cpp.SunOS-sparc	:= -Wall -shared
LINTFLAGS.cpp.SunOS-sparc	 = $(CFLAGS.cc.SunOS-sparc)
DOCFLAGS.cpp.SunOS-sparc	:= 
LIB_PFX.cpp.SunOS-sparc	:= lib
LIB_SFX.cpp.SunOS-sparc	:= .so
EXE_PFX.cpp.SunOS-sparc	:= 
EXE_SFX.cpp.SunOS-sparc	:= 




$(OBJDIR)/%.o	: %.S
	@echo  $(CFLAGS) $(CFLAGS.cpp) $(CFLAGS.cpp.$(ARCH)) > $@.cflags ;
	$(COMPILE.cpp.$(ARCH)) @$@.cflags $<

$(OBJDIR)/%.o	: %.s
	@echo  $(CFLAGS) $(CFLAGS.cpp) $(CFLAGS.cpp.$(ARCH)) > $@.cflags ;
	$(COMPILE.cpp.$(ARCH)) @$@.cflags $<

$(OBJDIR)/%.o	: %.cpp
	@echo  $(CFLAGS) $(CFLAGS.cpp) $(CFLAGS.cpp.$(ARCH)) > $@.cflags ;
	$(COMPILE.cpp.$(ARCH)) @$@.cflags $<

$(OBJDIR)/%.i	: /%.cpp
	@echo  $(CFLAGS) $(CFLAGS.cpp) $(CFLAGS.cpp.$(ARCH)) -E > $@.cflags ;
	$(COMPILE.cpp.$(ARCH)) @$@.cflags -E $<

$(OBJDIR)/%.ln	: %.cpp
	@echo  $(LINTFLAGS) $(LINTFLAGS.cpp) $(LINTFLAGS.cpp.$(ARCH)) > $@.lintflags ;
	$(LINT.cpp.$(ARCH)) @$@.lintflags $<

$(DOCDIR)/%.html: $(SRCDIR)/%.cpp
	@echo  $(DOCFLAGS) $(DOCFLAGS.cpp) $(DOCFLAGS.cpp.$(ARCH)) > $@.docflags ;
	$(DOC.cpp.$(ARCH)) @$@.docflags $<

.lib.$(LANGUAGE):	$(TGTDIR)/$(LIB_NM)
$(LIB_NM): $(TGTDIR)/$(LIB_NM)
$(TGTDIR)/$(LIB_NM): $(objs.$(LANGUAGE)) $(EXTRA_OBJS)
	@echo 	$(ARFLAGS) $(ARFLAGS.$(LANGUAGE)) $(ARFLAGS.$(LANGUAGE).$(ARCH)) > $@.arflags;
	$(AR.$(LANGUAGE).$(ARCH)) @$@.arflags $@ $^ 	

.exe.$(LANGUAGE):	$(TGTDIR)/$(EXE_NM)
$(EXE_NM): $(TGTDIR)/$(EXE_NM)
$(TGTDIR)/$(EXE_NM): $(objs.$(LANGUAGE)) $(EXTRA_OBJS) 
	@echo $(LDFLAGS) $(LDFLAGS.$(LANGUAGE)) $(LDFLAGS.$(LANGUAGE).$(ARCH)) > $@.ldflags;
	$(LD.$(LANGUAGE).$(ARCH)) @$@.ldflags $^ \
	    $(LIBS) $(LIBS.$(LANGUAGE)) $(LIBS.$(LANGUAGE).$(ARCH)) 


