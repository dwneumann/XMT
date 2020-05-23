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
GNUROOT			:= arm-none-eabi
COMPILE.cc.STM32F4	:= $(GNUROOT)-g++
LD.cc.STM32F4		:= $(GNUROOT)-g++
AR.cc.STM32F4		:= $(GNUROOT)-ar
DOC.cc.STM32F4		:= $(XMTBUILD)/bin/srcdoc 
LINT.cc.STM32F4		:= echo lint not installed
OBJCOPY.cc.STM32F4	:= $(GNUROOT)-objcopy
LIB_PFX.cc.STM32F4	:= lib
LIB_SFX.cc.STM32F4	:= .a
EXE_PFX.cc.STM32F4	:= 
EXE_SFX.cc.STM32F4	:= .elf

#**********************************************************************
# This is the place to define default flags and recipes
# that are specific to THIS target platform for THIS language.
#	-mcpu=cortex-m4+nofp -mfloat-abi=hard -mfpu=auto -D__FPU_PRESENT	
#**********************************************************************

MCU	= -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb -D__FPU_PRESENT=1	
CFLAGS.cc.STM32F4 += -Wall -Wno-strict-aliasing 					\
	-Wno-attributes -Wno-unused-function -Wno-unused-const-variable 	\
	-std=gnu99 -g3 -Os -MMD -MP						\
	$(MCU) --specs=nano.specs 						\
	-DSTM32F4xx -DARM_MATH_CM4 -DCORE_M4					\
	-mlittle-endian -mthumb -mthumb-interwork				\
	-fstack-usage -fdata-sections -ffunction-sections -fmessage-length=0	\
	-fno-builtin -fsingle-precision-constant 
 			
LDFLAGS.cc.STM32F4	+= $(MCU) -specs=nano.specs -specs=nosys.specs	\
	-Wl,-Map=$(TGTDIR)/$(PKG_NM).map -Wl,--cref -Wl,--gc-sections 

ARFLAGS.cc.STM32F4	+= -rscDv
LINTFLAGS.cc.STM32F4	+= $(CFLAGS.cc.STM32F4)
DOCFLAGS.cc.STM32F4	+= 

elf: exe

bin: exe
	$(OBJCOPY.cc.STM32F4) -O binary $(TGTDIR)/$(EXE_NM) $(TGTDIR)/$(PKG_NM).bin

hex: exe
	$(OBJCOPY.cc.STM32F4) -O ihex $(TGTDIR)/$(EXE_NM) $(TGTDIR)/$(PKG_NM).hex

$(OBJDIR)/%.o	: %.S
	@mkdir -p $(@D)
	@echo $(CFLAGS) $(CFLAGS.c) $(CFLAGS.cc.$(ARCH)) > $@.cflags ; 
	$(COMPILE.cc.$(ARCH)) @$@.cflags $< 

$(OBJDIR)/%.o	: %.s
	@mkdir -p $(@D)
	@echo $(CFLAGS) $(CFLAGS.c) $(CFLAGS.cc.$(ARCH)) > $@.cflags ; 
	$(COMPILE.cc.$(ARCH)) @$@.cflags $< 

$(OBJDIR)/%.o	: %.c
	@mkdir -p $(@D)
	@echo $(CFLAGS) $(CFLAGS.c) $(CFLAGS.cc.$(ARCH)) > $@.cflags ; 
	$(COMPILE.cc.$(ARCH)) @$@.cflags $< 

$(OBJDIR)/%.i	: /%.c
	@mkdir -p $(@D)
	@echo -E $(CFLAGS) $(CFLAGS.c) $(CFLAGS.cc.$(ARCH)) > $@.cflags ; 
	$(COMPILE.cc.$(ARCH)) @$@.cflags $< 

$(OBJDIR)/%.ln	: %.c
	@mkdir -p $(@D)
	@echo $(LINTFLAGS) $(LINTFLAGS.c) $(LINTFLAGS.cc.$(ARCH)) > $@.lintflags ; 
	$(LINT.cc.$(ARCH)) @$@.lintflags $< 

$(DOCDIR)/%.html: $(SRCDIR)/%.c
	@mkdir -p $(@D)
	@echo $(DOCFLAGS) $(DOCFLAGS.c) $(DOCFLAGS.cc.$(ARCH)) > $@.docflags ; 
	$(DOC.cc.$(ARCH)) @$@.docflags $< 

.lib.$(LANGUAGE):	$(TGTDIR)/$(LIB_NM)
$(LIB_NM): $(TGTDIR)/$(LIB_NM)
$(TGTDIR)/$(LIB_NM): $(objs.$(LANGUAGE)) $(EXTRA_OBJS)
	@mkdir -p $(@D)
	@echo 	$(ARFLAGS) $(ARFLAGS.$(LANGUAGE)) $(ARFLAGS.$(LANGUAGE).$(ARCH)) > $@.arflags;
	$(AR.$(LANGUAGE).$(ARCH)) @$@.arflags $@ $^ 	

.exe.$(LANGUAGE):	$(TGTDIR)/$(EXE_NM)
$(EXE_NM): $(TGTDIR)/$(EXE_NM)
$(TGTDIR)/$(EXE_NM): $(objs.$(LANGUAGE)) $(EXTRA_OBJS) 
	@mkdir -p $(@D)
	@echo $(LDFLAGS) $(LDFLAGS.$(LANGUAGE)) $(LDFLAGS.$(LANGUAGE).$(ARCH)) > $@.ldflags;
	$(LD.$(LANGUAGE).$(ARCH)) @$@.ldflags $^ \
	    $(LIBS) $(LIBS.$(LANGUAGE)) $(LIBS.$(LANGUAGE).$(ARCH)) 


