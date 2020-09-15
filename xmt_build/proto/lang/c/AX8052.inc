#************************************************************************
#*   Package	: xmt_build
#*   Synopsis	: included by $(XMTBUILD)/proto/lang/<language>/generic.inc
#*   Purpose	: 
#*			  This Makefile segment adds architecture support to
#*			  $(XMTBUILD)/proto/lang/<language>/generic.inc
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

arch := AX8052
#**********************************************************************
# define program paths...
#**********************************************************************
axsdb					= "c:\Programs\AXSEM\AXSDB"
ccroot					= "c:\Programs\SDCC"
DOCER.$(lang).$(arch)	= $(DOCER.$(lang))
LINTER.$(lang).$(arch)	= $(LINTER.$(lang))
COMPILER.$(lang).$(arch)= "$(ccroot)\sdcc"
LINKER.$(lang).$(arch)	= "$(ccroot)\sdcc"
ARCHIVER.$(lang).$(arch)= "$(ccroot)\sdcclib"
LIB_PFX.$(lang).$(arch)	= $(LIB_PFX).$(lang)
LIB_SFX.$(lang).$(arch)	= .a
EXE_PFX.$(lang).$(arch)	= 
EXE_SFX.$(lang).$(arch)	= .hex


# SDCC doesn't grok .o file extension.  Must redefine rules & variables to use .rel
objs.$(lang)	= $(patsubst $(SRCDIR)/%.$(lang),$(OBJDIR)/%.rel,$(srcs.$(lang)))

#**********************************************************************
# This is the place to define default flags that are specific to THIS 
# platform and THIS language.
#**********************************************************************

#*** model-small-stack-auto
#SMALL_STACK_AUTO	= $(DOSPROJECT)/AX5043/small-stack-auto
#SYS_INCLUDES.$(lang).$(arch) =								\
#		   -I$(ccroot)/include								\
#		   -I$(SMALL_STACK_AUTO)/libmf/src					\
#		   -I$(SMALL_STACK_AUTO)/libaxdvk2/src				\
#		   -I$(SMALL_STACK_AUTO)/libax5043/src	
#CFLAGS.$(lang).$(arch) += -mmcs51 --verbose --model-small --stack-auto -DRADIO=5043 $(SYS_INCLUDES.$(lang).$(arch))
#LINKERFLAGS.$(lang).$(arch) += -mmcs51 --verbose --model-small --stack-auto -muwx -M	\
#			--xram-size 8192 --iram-size 256 --code-size 64512				\
#			--code-loc 0x0000 --xram-loc 0x0000 --data-loc 0x08				\
#			-L$(ccroot)/lib													\
#			-L$(axsdb)/libreent/sdcc										\
#			-L$(SMALL_STACK_AUTO)/libaxdvk2/tgt/AX8052						\
#			-L$(SMALL_STACK_AUTO)/libmf/tgt/AX8052							\
#			-L$(SMALL_STACK_AUTO)/libax5043/tgt/AX8052						\
#			-l libmf_small_stack_auto										\
#			-l libaxdvk2_small_stack_auto									\
#			-l libax5043_small_stack_auto				

#*** model-small
SYS_INCLUDES.$(lang).$(arch) =												\
		   -I$(ccroot)/include												\
		   -I$(axsdb)/libmf/include											\
		   -I$(axsdb)/libaxdvk2/include										\
		   -I$(axsdb)/libax5043/include	
CFLAGS.$(lang).$(arch) += -mmcs51 --verbose --model-small -DRADIO=5043 $(SYS_INCLUDES.$(lang).$(arch))
LINKERFLAGS.$(lang).$(arch) += -mmcs51 --verbose --model-small -muwx -M		\
			--xram-size 8192 --iram-size 256 --code-size 64512				\
			--code-loc 0x0000 --xram-loc 0x0000 --data-loc 0x08				\
			-L$(ccroot)/lib													\
			-L$(axsdb)/libreent/sdcc										\
			-L$(axsdb)/libaxdvk2/sdcc										\
			-L$(axsdb)/libmf/sdcc											\
			-L$(axsdb)/libax5043/sdcc										\
			-l libmf														\
			-l libaxdvk2													\
			-l libax5043				


$(OBJDIR)/%.rel	: $(SRCDIR)/%.s
	@mkdir -p $(@D)
	$(COMPILER.$(lang).$(arch)) $(CFLAGS) $(CFLAGS.$(lang)) $(CFLAGS.$(lang).$(arch)) -c $< -o $@

$(OBJDIR)/%.rel	: $(SRCDIR)/%.$(lang)
	@mkdir -p $(@D)
	$(COMPILER.$(lang).$(arch)) $(CFLAGS) $(CFLAGS.$(lang)) $(CFLAGS.$(lang).$(arch)) -c $< -o $@


.PHONY: bin.$(lang).$(arch)
bin.$(lang).$(arch): exe.$(lang).$(arch)
	$(OBJCOPY.$(lang).$(arch)) -O binary $(TGTDIR)/$(EXE_NM) $(TGTDIR)/$(PKG_NM).bin

.PHONY: hex.$(lang).$(arch)
hex.$(lang).$(arch): exe.$(lang).$(arch)
	$(OBJCOPY.$(lang).$(arch)) -O ihex $(TGTDIR)/$(EXE_NM) $(TGTDIR)/$(PKG_NM).hex

.PHONY: analyze.$(lang).$(arch) 
analyze.$(lang).$(arch) :
	$(LINTER.$(LANGUAGE).$(ARCH))	\
		$(LINTFLAGS) $(LINTFLAGS.$(LANGUAGE)) $(LINTFLAGS.$(LANGUAGE).$(ARCH))  \
		$(srcs.$(lang)) $(hdrs.$(lang))

.PHONY: docs.$(lang).$(arch) 
docs.$(lang).$(arch) :
	$(DOCER.$(LANGUAGE).$(ARCH))	\
		$(DOCFLAGS) $(DOCFLAGS.$(LANGUAGE)) $(DOCFLAGS.$(LANGUAGE).$(ARCH))

$(OBJDIR)/%.i	: $(SRCDIR)/%.$(lang)
	@mkdir -p $(@D)
	@echo -E $(CFLAGS) $(CFLAGS.$(lang)) $(CFLAGS.$(lang).$(arch)) > $@.cflags ; 
	$(COMPILER.$(lang).$(arch)) @$@.cflags $< 

.PHONY: lib.$(lang).$(arch)
lib.$(lang).$(arch):	$(TGTDIR)/$(LIB_NM)
$(LIB_NM): $(TGTDIR)/$(LIB_NM)
$(TGTDIR)/$(LIB_NM): $(objs.$(lang)) $(EXTRA_OBJS)
	@mkdir -p $(@D)
	@echo 	$(ARFLAGS) $(ARFLAGS.$(lang)) $(ARFLAGS.$(lang).$(arch)) > $@.arflags;
	$(ARCHIVER.$(lang).$(arch)) @$@.arflags $@ $^ 	

.PHONY: exe.$(lang).$(arch)
exe.$(lang).$(arch):	$(TGTDIR)/$(EXE_NM)
$(EXE_NM): $(TGTDIR)/$(EXE_NM)
$(TGTDIR)/$(EXE_NM): $(objs.$(lang)) $(EXTRA_OBJS) 
	@mkdir -p $(@D)
	@echo $(LDFLAGS) $(LDFLAGS.$(lang)) $(LDFLAGS.$(lang).$(arch)) > $@.ldflags;
	$(LINKER.$(lang).$(arch)) @$@.ldflags $^ \
		$(LIBS) $(LIBS.$(lang)) $(LIBS.$(lang).$(arch)) 

.PHONY: flash
flash:  $(TGTDIR)/$(EXE_NM)
	axsdb --flashprog $(TGTDIR)/$(EXE_NM)

