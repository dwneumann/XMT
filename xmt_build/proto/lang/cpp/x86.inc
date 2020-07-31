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
COMPILE.cpp.x86	= g++
LD.cpp.x86	= g++
AR.cpp.x86	= ar
DOC.cpp.x86	= $(XMTBUILD)/bin/srcdoc 
LINT.cpp.x86	= echo lint not installed
LIB_PFX.cpp.x86	= lib
LIB_SFX.cpp.x86	= .a
EXE_PFX.cpp.x86	= 
EXE_SFX.cpp.x86	= 

#**********************************************************************
# This is the place to define default flags that are specific to THIS 
# platform and THIS language.
#**********************************************************************
CFLAGS.cpp.x86 += -Wall -Wno-strict-aliasing 					\
	-Wno-attributes -Wno-unused-function -Wno-unused-const-variable 	\
	-g3 -MMD -MP							\
	-isystem /usr/include/x86_64-linux-gnu
#	-g3 -Os -MMD -MP							\

LDFLAGS.cpp.x86		+= 
ARFLAGS.cpp.x86		+= -r
LINTFLAGS.cpp.x86	+= $(CFLAGS.cpp.x86)
DOCFLAGS.cpp.x86	+= 



$(OBJDIR)/%.o	: %.S
	@mkdir -p $(@D)
	@echo $(CFLAGS) $(CFLAGS.cpp) $(CFLAGS.cpp.x86) > $@.cflags ; 
	$(COMPILE.cpp.x86) @$@.cflags $< 

$(OBJDIR)/%.o	: %.s
	@mkdir -p $(@D)
	@echo $(CFLAGS) $(CFLAGS.cpp) $(CFLAGS.cpp.x86) > $@.cflags ; 
	$(COMPILE.cpp.x86) @$@.cflags $< 

$(OBJDIR)/%.o	: %.cpp
	@mkdir -p $(@D)
	@echo $(CFLAGS) $(CFLAGS.cpp) $(CFLAGS.cpp.x86) > $@.cflags ; 
	$(COMPILE.cpp.x86) @$@.cflags $< 

$(OBJDIR)/%.i	: %.cpp
	@mkdir -p $(@D)
	@echo -E $(CFLAGS) $(CFLAGS.cpp) $(CFLAGS.cpp.x86) > $@.cflags ; 
	$(COMPILE.cpp.x86) @$@.cflags $< 

$(OBJDIR)/%.ln	: %.cpp
	@mkdir -p $(@D)
	@echo $(LINTFLAGS) $(LINTFLAGS.cpp) $(LINTFLAGS.cpp.x86) > $@.lintflags ; 
	$(LINT.cpp.x86) @$@.lintflags $< 

$(DOCDIR)/%.html: $(SRCDIR)/%.cpp
	@mkdir -p $(@D)
	@echo $(DOCFLAGS) $(DOCFLAGS.cpp) $(DOCFLAGS.cpp.x86) > $@.docflags ; 
	$(DOC.cpp.x86) @$@.docflags $< 

.lib.cpp:  $(TGTDIR)/$(LIB_NM)
$(LIB_NM): $(TGTDIR)/$(LIB_NM)
$(TGTDIR)/$(LIB_NM): $(objs.cpp) $(EXTRA_OBJS)
	@mkdir -p $(@D)
	@echo 	$(ARFLAGS) $(ARFLAGS.cpp) $(ARFLAGS.cpp.x86) > $@.arflags;
	$(AR.cpp.x86) @$@.arflags $@ $^ 	

.exe.cpp:  $(TGTDIR)/$(EXE_NM)
$(EXE_NM): $(TGTDIR)/$(EXE_NM)
$(TGTDIR)/$(EXE_NM): $(objs.cpp) $(EXTRA_OBJS) 
	@mkdir -p $(@D)
	@echo $(LDFLAGS) $(LDFLAGS.cpp) $(LDFLAGS.cpp.x86) > $@.ldflags;
	$(LD.cpp.x86) @$@.ldflags $^ \
	    $(LIBS) $(LIBS.cpp) $(LIBS.cpp.x86) 



