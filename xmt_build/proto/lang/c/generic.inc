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

ifdef do_vars
#************************************************************************
# DO ALL VARIABLE ASSIGNMENTS HERE
#************************************************************************


#   := assignements are evaluated during lexical scan;
#    = assignemtns are recursively evaluated during rule parsing
srcs.c	:= $(wildcard $(SRCDIR)/*.c)
hdrs.c	:= $(wildcard $(SRCDIR)/*.h)
objs.c	:= $(patsubst $(SRCDIR)/%.c,$(OBJDIR)/%.o,$(srcs.c))
docs.c	:= $(patsubst $(SRCDIR)/%.c,$(DOCDIR)/%.html,$(srcs.c))
lnts.c	:= $(patsubst $(SRCDIR)/%.c,$(OBJDIR)/%.ln,$(srcs.c))

#**********************************************************************
# pull in sources from vendor tree rooted at VENDOR_ROOT
#**********************************************************************
VENDOR_ROOT	= $(SRCDIR)/vendor
vendor_srcdirs	:= $(sort $(dir $(shell find $(VENDOR_ROOT) -name "*.$(LANGUAGE)")))
vendor_srcfiles	:= $(sort $(notdir $(shell find $(VENDOR_ROOT) -name "*.$(LANGUAGE)")))
vendor_sdirs	:= $(sort $(dir $(shell find $(VENDOR_ROOT) -name "*.[sS]")))
vendor_sfiles	:= $(sort $(notdir $(shell find $(VENDOR_ROOT) -name "*.[sS]")))
vendor_objfiles	:= $(patsubst %,$(OBJDIR)/%,$(vendor_srcfiles:.$(LANGUAGE)=.o) $(vendor_sfiles:.s=.o))
vendor_hdirs	:= $(sort $(dir $(shell find $(VENDOR_ROOT) -name "*.h")))
vendor_hfiles	:= $(sort $(notdir $(shell find $(VENDOR_ROOT) -name "*.h")))
vendor_incs	:= $(patsubst %,-I%,$(vendor_hdirs))

vpath %.c $(SRCDIR) $(vendor_srcdirs)
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
CFLAGS.c	+=  -c -o $@ 
ARFLAGS.c	+= 
LDFLAGS.c	+= -o $@
LINTFLAGS.c	+= $(CFLAGS.c)
DOCFLAGS.c	+= -o $@

endif
ifdef do_rules
#************************************************************************
# DO TARGET RULE OVERRIDES HERE
#************************************************************************


#************************************************************************
endif
