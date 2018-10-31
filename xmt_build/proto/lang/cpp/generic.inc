#************************************************************************
#*   $Version:$
#*   Package	: xmt_build
#*   Synopsis	: included by $(XMTBUILD)/proto/Makefile.top
#*   Purpose	: 
#*              This Makefile segment adds language support to
#*              $(XMTBUILD)/proto/Makefile.top
#*
#*   To add support for a new target architecture,  clone any existing
#*   <architecture>.inc file & alter program paths & flags appropriately.
#*   Remember to also update $(XMTBUILD)/proto/cshrc  to add the new
#*   architecture to XMTBUILD_SUPP_ARCHS.
#*
#*  Copyright (c) 1998	Neumann & Associates Information Systems Inc.
#*  			legal.info@neumann-associates.cppom
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

srcs.cpp	= $(wildcard $(SRCDIR)/*.cpp)
hdrs.cpp	= $(wildcard $(SRCDIR)/*.h)
objs.cpp	= $(patsubst $(SRCDIR)/%.cpp,$(OBJDIR)/%.o,$(srcs.cpp))
docs.cpp	= $(patsubst $(SRCDIR)/%.cpp,$(DOCDIR)/%.html,$(srcs.cpp))
lnts.cpp	= $(patsubst $(SRCDIR)/%.cpp,$(OBJDIR)/%.ln,$(srcs.cpp))

#**********************************************************************
# pull in sources from vendor tree rooted at VENDOR_ROOT
#**********************************************************************
VENDOR_ROOT	= $(SRCDIR)/vendor
vendor_srcdirs	= $(sort $(dir $(shell find $(VENDOR_ROOT) -name "*.$(LANGUAGE)")))
vendor_srcfiles	= $(sort $(notdir $(shell find $(VENDOR_ROOT) -name "*.$(LANGUAGE)")))
vendor_sdirs	= $(sort $(dir $(shell find $(VENDOR_ROOT) -name "*.[sS]")))
vendor_sfiles	= $(sort $(notdir $(shell find $(VENDOR_ROOT) -name "*.[sS]")))
vendor_objfiles	= $(patsubst %,$(OBJDIR)/%,$(vendor_srcfiles:.$(LANGUAGE)=.o) $(vendor_sfiles:.s=.o))
vendor_hdirs	= $(sort $(dir $(shell find $(VENDOR_ROOT) -name "*.h")))
vendor_hfiles	= $(sort $(notdir $(shell find $(VENDOR_ROOT) -name "*.h")))
vendor_incs	= $(patsubst %,-I%,$(vendor_hdirs))

vpath %.cpp $(SRCDIR) $(vendor_srcdirs)
vpath %.i $(SRCDIR) $(vendor_srcdirs)
vpath %.ln $(SRCDIR) $(vendor_srcdirs)
vpath %.html $(SRCDIR) $(vendor_srcdirs)
vpath %.h $(SRCDIR) $(vendor_hdirs)
vpath %.s $(SRCDIR) $(vendor_sdirs)
vpath %.S $(SRCDIR) $(vendor_sdirs)

#**********************************************************************
# This is the place to define default flags and recipes
# that are common to ALL target architectures for THIS language.
#**********************************************************************
CFLAGS.cpp	+= -c -o $@
ARFLAGS.cpp	+= 
LDFLAGS.cpp	+= -o $@
LINTFLAGS.cpp	+= $(CFLAGS.cpp)
DOCFLAGS.cpp	+= -o $@

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

