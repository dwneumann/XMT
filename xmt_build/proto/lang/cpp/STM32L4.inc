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


ifdef do_vars
#************************************************************************
# DO ALL VARIABLE ASSIGNMENTS HERE
#************************************************************************


CMSIS	= $(STM32_FW)/Libraries/CMSIS

#**********************************************************************
# define program paths...
#**********************************************************************
GNUROOT			:= arm-none-eabi
COMPILE.cpp.STM32L4	:= $(GNUROOT)-gcc
LD.cpp.STM32L4		:= $(GNUROOT)-gcc
AR.cpp.STM32L4		:= $(GNUROOT)-ar
DOC.cpp.STM32L4		:= $(XMTBUILD)/bin/srcdoc 
LINT.cpp.STM32L4		:= echo lint not installed
OBJCOPY.cpp.STM32L4	:= $(GNUROOT)-objcopy
LIB_PFX.cpp.STM32L4	:= lib
LIB_SFX.cpp.STM32L4	:= .a
EXE_PFX.cpp.STM32L4	:= 
EXE_SFX.cpp.STM32L4	:= .elf

#**********************************************************************
# This is the place to define default flags that are specific to THIS 
# platform and THIS language.
#**********************************************************************
CFLAGS.cpp.STM32L4 += -Wall -mlittle-endian -mthumb -mcpu=cortex-m4 	\
		    -mthumb-interwork -mfloat-abi=hard -mfpu=fpv4-sp-d16 	

LDFLAGS.cpp.STM32L4	+= $(CFLAGS.cpp.STM32L4) 
ARFLAGS.cpp.STM32L4	+= -rscDv
LINTFLAGS.cpp.STM32L4	+= $(CFLAGS.cpp.STM32L4)
DOCFLAGS.cpp.STM32L4	+= 

endif
ifdef do_rules
#************************************************************************
# DO TARGET RULE OVERRIDES HERE
#************************************************************************


bin: exe
	$(OBJCOPY.cpp.STM32L4) -O binary $(TGTDIR)/$(EXE_NM) $(TGTDIR)/$(PKG_NM).bin

hex: exe
	$(OBJCOPY.cpp.STM32L4) -O ihex $(TGTDIR)/$(EXE_NM) $(TGTDIR)/$(PKG_NM).hex



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



#************************************************************************
endif
