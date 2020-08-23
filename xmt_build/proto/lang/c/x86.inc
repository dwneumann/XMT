#************************************************************************
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

override lang := c
override arch := x86
#**********************************************************************
# define program paths...
#**********************************************************************
DOCER.$(lang).$(arch)	= $(DOCER.$(lang))
LINTER.$(lang).$(arch)	= $(LINTER.$(lang))
COMPILER.$(lang).$(arch)= /usr/bin/gcc
LINKER.$(lang).$(arch)  = /usr/bin/ld
ARCHIVER.$(lang).$(arch)= /usr/bin/ar
OBJCOPY.$(lang).$(arch)	= echo no objcopy for $(arch)
LIB_PFX.$(lang).$(arch)	= $(LIB_PFX).$(lang)
LIB_SFX.$(lang).$(arch)	= .so
EXE_PFX.$(lang).$(arch)	= 
EXE_SFX.$(lang).$(arch)	= 

#**********************************************************************
# This is the place to define default flags and recipes
# that are specific to THIS target platform for THIS language.
#**********************************************************************
CFLAGS.$(lang).$(arch) = -Wall -Wno-strict-aliasing -Wno-write-strings 		\
	-Wno-attributes -Wno-unused-function -Wno-unused-const-variable 	        \
	-std=gnu99 -g -MMD -MP							                            \
	-isystem /usr/include/x86_64-linux-gnu

LDFLAGS.$(lang).$(arch)	    = -m32
ARFLAGS.$(lang).$(arch)	    = -r
LINTFLAGS.$(lang).$(arch)	= 
DOCFLAGS.$(lang).$(arch)	= 

bin: exe

lint.$(lang).$(arch) :
	$(LINTER.$(LANGUAGE).$(ARCH))    \
        $(LINTFLAGS) $(LINTFLAGS.$(LANGUAGE)) $(LINTFLAGS.$(LANGUAGE).$(ARCH))  \
        $(srcs.$(lang)) $(hdrs.$(lang))
    
docs.$(lang).$(arch) :
	$(DOCER.$(LANGUAGE).$(ARCH))    \
        $(DOCFLAGS) $(DOCFLAGS.$(LANGUAGE)) $(DOCFLAGS.$(LANGUAGE).$(ARCH))

$(OBJDIR)/%.o	: %.s
	@mkdir -p $(@D)
	@echo $(CFLAGS) $(CFLAGS.$(lang)) $(CFLAGS.$(lang).$(arch)) > $@.cflags ; 
	$(COMPILER.$(lang).$(arch)) @$@.cflags $< 

$(OBJDIR)/%.o	: %.$(lang)
	@mkdir -p $(@D)
	@echo $(CFLAGS) $(CFLAGS.$(lang)) $(CFLAGS.$(lang).$(arch)) > $@.cflags ; 
	$(COMPILER.$(lang).$(arch)) @$@.cflags $< 

$(OBJDIR)/%.i	: $(SRCDIR)/%.$(lang)
	@mkdir -p $(@D)
	@echo -E $(CFLAGS) $(CFLAGS.$(lang)) $(CFLAGS.$(lang).$(arch)) > $@.cflags ; 
	$(COMPILER.$(lang).$(arch)) @$@.cflags $< 

$(DOCDIR)/%.html: $(SRCDIR)/%.$(lang)
	@mkdir -p $(@D)
	@echo $(DOCFLAGS) $(DOCFLAGS.$(lang)) $(DOCFLAGS.$(lang).$(arch)) > $@.docflags ; 
	$(DOC.$(lang).$(arch)) @$@.docflags $< 

.lib.$(lang):	$(TGTDIR)/$(LIB_NM)
$(LIB_NM): $(TGTDIR)/$(LIB_NM)
$(TGTDIR)/$(LIB_NM): $(objs.$(lang)) $(EXTRA_OBJS)
	@mkdir -p $(@D)
	@echo 	$(ARFLAGS) $(ARFLAGS.$(lang)) $(ARFLAGS.$(lang).$(arch)) > $@.arflags;
	$(ARCHIVER.$(lang).$(arch)) @$@.arflags $@ $^ 	

.exe.$(lang):	$(TGTDIR)/$(EXE_NM)
$(EXE_NM): $(TGTDIR)/$(EXE_NM)
$(TGTDIR)/$(EXE_NM): $(objs.$(lang)) $(EXTRA_OBJS) 
	@mkdir -p $(@D)
	@echo $(LDFLAGS) $(LDFLAGS.$(lang)) $(LDFLAGS.$(lang).$(arch)) > $@.ldflags;
	$(LINKER.$(lang).$(arch)) @$@.ldflags $^ \
	    $(LIBS) $(LIBS.$(lang)) $(LIBS.$(lang).$(arch)) 
