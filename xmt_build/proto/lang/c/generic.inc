#************************************************************************
#*   Package	: xmt_build
#*   Synopsis	: included by $(XMTBUILD)/proto/Makefile.top
#*   Purpose	: 
#*			  This Makefile segment adds language support to
#*			  $(XMTBUILD)/proto/Makefile.top
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
#	= assignments are recursively evaluated during rule parsing
lang	:= c

# we specifically do NOT want to recursively search below SRCDIR for sources
# because there may be platform-specific code in different subdirectories
# that we need to include or exclude at the package level.
srcs.$(lang)	= $(wildcard $(SRCDIR)/*.$(lang))
hdrs.$(lang)	= $(wildcard $(SRCDIR)/*.h)
objs.$(lang)	= $(patsubst $(SRCDIR)/%.$(lang),$(OBJDIR)/%.o,$(srcs.$(lang)))
docs.$(lang)	= $(patsubst $(SRCDIR)/%.$(lang),$(DOCDIR)/%.html,$(srcs.$(lang)))
lnts.$(lang)	= $(patsubst $(SRCDIR)/%.$(lang),$(OBJDIR)/%.ln,$(srcs.$(lang)))

#**********************************************************************
# if directory THIRDPARTY_SRCS exists
# recurse down into it and gather all 3rd party sources and includes found there.
# There could be different third party directories for different build configurations
# so THIRDPARTY_SRCS needs to be set at the package level.
#**********************************************************************
tpdir		= $(shell [ -d "$(THIRDPARTY_SRCS)" ] && echo "$(THIRDPARTY_SRCS)" || echo "")
ifneq ($(strip $(tpdir)),)
  thirdparty_c		= $(sort $(shell find -L $(tpdir) -name "*.$(lang)"))
  thirdparty_h		= $(sort $(shell find -L $(tpdir) -name "*.h"))
  thirdparty_s		= $(sort $(shell find -L $(tpdir) -name "*.s"))
  thirdparty_S		= $(sort $(shell find -L $(tpdir) -name "*.S"))
  thirdparty_cdirs	= $(sort $(dir $(thirdparty_c)))
  thirdparty_hdirs	= $(sort $(dir $(thirdparty_h)))
  thirdparty_sdirs	= $(sort $(dir $(thirdparty_s)))
  thirdparty_Sdirs	= $(sort $(dir $(thirdparty_S)))
  thirdparty_cfiles	= $(sort $(notdir $(thirdparty_c)))
  thirdparty_hfiles	= $(sort $(notdir $(thirdparty_h)))
  thirdparty_sfiles	= $(sort $(notdir $(thirdparty_s)))
  thirdparty_Sfiles	= $(sort $(notdir $(thirdparty_S)))
  thirdparty_includes	= $(sort $(patsubst %,-I%,$(thirdparty_hdirs)))
  thirdparty_objfiles	= $(patsubst  %,$(OBJDIR)/%,$(notdir $(thirdparty_cfiles:.$(lang)=.o)))
  thirdparty_objfiles	+= $(patsubst %,$(OBJDIR)/%,$(notdir $(thirdparty_sfiles:.s=.o)))
  thirdparty_objfiles	+= $(patsubst %,$(OBJDIR)/%,$(notdir $(thirdparty_Sfiles:.S=.o)))
  vpath	%.$(lang)	$(SRCDIR) $(thirdparty_cdirs)
  vpath	%.i	$(SRCDIR) $(thirdparty_cdirs)
  vpath	%.ln	$(SRCDIR) $(thirdparty_cdirs)
  vpath	%.html	$(SRCDIR) $(thirdparty_cdirs)
  vpath	%.h	$(SRCDIR) $(thirdparty_hdirs)
  vpath	%.s	$(SRCDIR) $(thirdparty_sdirs)
  vpath	%.S	$(SRCDIR) $(thirdparty_Sdirs)
else
  vpath	%.$(lang)	$(SRCDIR) 
  vpath	%.i	$(SRCDIR) 
  vpath	%.ln	$(SRCDIR) 
  vpath	%.html	$(SRCDIR) 
  vpath	%.h	$(SRCDIR) 
  vpath	%.s	$(SRCDIR) 
  vpath	%.S	$(SRCDIR) 
endif

#**********************************************************************
# This is the place to define programs, flags and recipes
# that are common to ALL target architectures for *THIS* language.
# Language-specific values inherit from global (language-independent) defines
# by default, but can be overridden in a project or package level Makefile
#**********************************************************************
DOCER.$(lang)		= $(DOCER)
LINTER.$(lang)		= $(LINTER)
GCCROOT				= $(XMTEXT)/site/opt/gcc-arm-none-eabi
COMPILER.$(lang)	= $(GCCROOT)/bin/arm-none-eabi-gcc
LINKER.$(lang)  	= $(GCCROOT)/bin/arm-none-eabi-gcc
ARCHIVER.$(lang)  	= $(GCCROOT)/bin/arm-none-eabi-ar
OBJCOPY.$(lang)		= $(GCCROOT)/bin/arm-none-eabi-objcopy
LIB_PFX.$(lang)		= lib
LIB_SFX.$(lang)		= .a
EXE_PFX.$(lang)		= 
EXE_SFX.$(lang)		= .elf
CFLAGS.$(lang)		+= -c -o $@ 
ARFLAGS.$(lang)		+= -rscDv
LDFLAGS.$(lang)		+= -o $@
LINTFLAGS.$(lang)	+= 
DOCFLAGS.$(lang)	+= $(PROJECT)/proto/Doxyfile

## Define recipes in $(XMTBUILD)/proto/lang/$(LANGUAGE)/$(ARCH)
