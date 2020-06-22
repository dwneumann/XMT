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
COMPILE.cc.x86	= g++
LD.cc.x86	= g++
AR.cc.x86	= ar
DOC.cc.x86	= $(XMTBUILD)/bin/srcdoc 
LINT.cc.x86	= echo lint not installed
LIB_PFX.cc.x86	= lib
LIB_SFX.cc.x86	= .a
EXE_PFX.cc.x86	= 
EXE_SFX.cc.x86	= 

#**********************************************************************
# This is the place to define default flags that are specific to THIS 
# platform and THIS language.
#**********************************************************************
CFLAGS.cc.x86 += -Wall -Wno-strict-aliasing 					\
	-Wno-attributes -Wno-unused-function -Wno-unused-const-variable 	\
	-g3 -Os -MMD -MP							\
	-isystem /usr/include/x86_64-linux-gnu

LDFLAGS.cc.x86	+= 
ARFLAGS.cc.x86	+= -r
LINTFLAGS.cc.x86	+= $(CFLAGS.cc.x86)
DOCFLAGS.cc.x86	+= 



$(OBJDIR)/%.o	: %.S
	@mkdir -p $(@D)
	@echo $(CFLAGS) $(CFLAGS.cc) $(CFLAGS.cc.x86) > $@.cflags ; 
	$(COMPILE.cc.x86) @$@.cflags $< 

$(OBJDIR)/%.o	: %.s
	@mkdir -p $(@D)
	@echo $(CFLAGS) $(CFLAGS.cc) $(CFLAGS.cc.x86) > $@.cflags ; 
	$(COMPILE.cc.x86) @$@.cflags $< 

$(OBJDIR)/%.o	: %.cc
	@mkdir -p $(@D)
	@echo $(CFLAGS) $(CFLAGS.cc) $(CFLAGS.cc.x86) > $@.cflags ; 
	$(COMPILE.cc.x86) @$@.cflags $< 

$(OBJDIR)/%.i	: %.cc
	@mkdir -p $(@D)
	@echo -E $(CFLAGS) $(CFLAGS.cc) $(CFLAGS.cc.x86) > $@.cflags ; 
	$(COMPILE.cc.x86) @$@.cflags $< 

$(OBJDIR)/%.ln	: %.cc
	@mkdir -p $(@D)
	@echo $(LINTFLAGS) $(LINTFLAGS.cc) $(LINTFLAGS.cc.x86) > $@.lintflags ; 
	$(LINT.cc.x86) @$@.lintflags $< 

$(DOCDIR)/%.html: $(SRCDIR)/%.cc
	@mkdir -p $(@D)
	@echo $(DOCFLAGS) $(DOCFLAGS.cc) $(DOCFLAGS.cc.x86) > $@.docflags ; 
	$(DOC.cc.x86) @$@.docflags $< 

.lib.cc:	$(TGTDIR)/$(LIB_NM)
$(LIB_NM): $(TGTDIR)/$(LIB_NM)
$(TGTDIR)/$(LIB_NM): $(objs.cc) $(EXTRA_OBJS)
	@mkdir -p $(@D)
	@echo 	$(ARFLAGS) $(ARFLAGS.cc) $(ARFLAGS.cc.x86) > $@.arflags;
	$(AR.cc.x86) @$@.arflags $@ $^ 	

.exe.cc:	$(TGTDIR)/$(EXE_NM)
$(EXE_NM): $(TGTDIR)/$(EXE_NM)
$(TGTDIR)/$(EXE_NM): $(objs.cc) $(EXTRA_OBJS) 
	@mkdir -p $(@D)
	@echo $(LDFLAGS) $(LDFLAGS.cc) $(LDFLAGS.cc.x86) > $@.ldflags;
	$(LD.cc.x86) @$@.ldflags $^ \
	    $(LIBS) $(LIBS.cc) $(LIBS.cc.x86) 



