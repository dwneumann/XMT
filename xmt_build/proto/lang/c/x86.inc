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
COMPILE.c.x86	= g++
LD.c.x86	= g++
AR.c.x86	= ar
DOC.c.x86	= $(XMTBUILD)/bin/srcdoc 
LINT.c.x86	= echo lint not installed
LIB_PFX.c.x86	= lib
LIB_SFX.c.x86	= .a
EXE_PFX.c.x86	= 
EXE_SFX.c.x86	= 

#**********************************************************************
# This is the place to define default flags that are specific to THIS 
# platform and THIS language.
#**********************************************************************
CFLAGS.c.x86 += -Wall -Wno-strict-aliasing 					\
	-Wno-attributes -Wno-unused-function -Wno-unused-const-variable 	\
	-m32 -g3 -Os -MMD -MP						\
	-isystem /usr/include/x86_64-linux-gnu

LDFLAGS.c.x86	+= $(CFLAGS.c.x86) 
ARFLAGS.c.x86	+= -r
LINTFLAGS.c.x86	+= $(CFLAGS.c.x86)
DOCFLAGS.c.x86	+= 



$(OBJDIR)/%.o	: %.S
	@mkdir -p $(@D)
	@echo $(CFLAGS) $(CFLAGS.c) $(CFLAGS.c.x86) > $@.cflags ; 
	$(COMPILE.c.x86) @$@.cflags $< 

$(OBJDIR)/%.o	: %.s
	@mkdir -p $(@D)
	@echo $(CFLAGS) $(CFLAGS.c) $(CFLAGS.c.x86) > $@.cflags ; 
	$(COMPILE.c.x86) @$@.cflags $< 

$(OBJDIR)/%.o	: %.c
	@mkdir -p $(@D)
	@echo $(CFLAGS) $(CFLAGS.c) $(CFLAGS.c.x86) > $@.cflags ; 
	$(COMPILE.c.x86) @$@.cflags $< 

$(OBJDIR)/%.i	: %.c
	@mkdir -p $(@D)
	@echo -E $(CFLAGS) $(CFLAGS.c) $(CFLAGS.c.x86) > $@.cflags ; 
	$(COMPILE.c.x86) @$@.cflags $< 

$(OBJDIR)/%.ln	: %.c
	@mkdir -p $(@D)
	@echo $(LINTFLAGS) $(LINTFLAGS.c) $(LINTFLAGS.c.x86) > $@.lintflags ; 
	$(LINT.c.x86) @$@.lintflags $< 

$(DOCDIR)/%.html: $(SRCDIR)/%.c
	@mkdir -p $(@D)
	@echo $(DOCFLAGS) $(DOCFLAGS.c) $(DOCFLAGS.c.x86) > $@.docflags ; 
	$(DOC.c.x86) @$@.docflags $< 

.lib.c:	$(TGTDIR)/$(LIB_NM)
$(LIB_NM): $(TGTDIR)/$(LIB_NM)
$(TGTDIR)/$(LIB_NM): $(objs.c) $(EXTRA_OBJS)
	@mkdir -p $(@D)
	@echo 	$(ARFLAGS) $(ARFLAGS.c) $(ARFLAGS.c.x86) > $@.arflags;
	$(AR.c.x86) @$@.arflags $@ $^ 	

.exe.c:	$(TGTDIR)/$(EXE_NM)
$(EXE_NM): $(TGTDIR)/$(EXE_NM)
$(TGTDIR)/$(EXE_NM): $(objs.c) $(EXTRA_OBJS) 
	@mkdir -p $(@D)
	@echo $(LDFLAGS) $(LDFLAGS.c) $(LDFLAGS.c.x86) > $@.ldflags;
	$(LD.c.x86) @$@.ldflags $^ \
	    $(LIBS) $(LIBS.c) $(LIBS.c.x86) 



