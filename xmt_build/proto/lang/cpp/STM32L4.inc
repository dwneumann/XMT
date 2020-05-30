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
COMPILE.cpp.STM32L4	:= $(GNUROOT)-g++
LD.cpp.STM32L4		:= $(GNUROOT)-g++
AR.cpp.STM32L4		:= $(GNUROOT)-ar
DOC.cpp.STM32L4		:= $(XMTBUILD)/bin/srcdoc 
LINT.cpp.STM32L4		:= echo lint not installed
OBJCOPY.cpp.STM32L4	:= $(GNUROOT)-objcopy
LIB_PFX.cpp.STM32L4	:= lib
LIB_SFX.cpp.STM32L4	:= .a
EXE_PFX.cpp.STM32L4	:= 
EXE_SFX.cpp.STM32L4	:= .elf

#**********************************************************************
# This is the place to define default flags and recipes
# that are specific to THIS target platform for THIS language.
#**********************************************************************

MCU	= -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb 
CFLAGS.cpp.STM32L4 += -Wall -Wno-strict-aliasing 				\
	-Wno-attributes -Wno-unused-function -Wno-unused-const-variable 	\
	-g3 -Os -MMD -MP							\
	$(MCU) --specs=nano.specs --specs=nosys.specs 			 	\
	-DSTM32L4xx -DARM_MATH_CM4 -DCORE_M4					\
	-mlittle-endian -mthumb -mthumb-interwork				\
	-fstack-usage -fdata-sections -ffunction-sections -fmessage-length=0	\
	-fno-builtin -fsingle-precision-constant 
 			

LDFLAGS.cpp.STM32L4	+= $(MCU) -Wl,-Map=$(TGTDIR)/$(PKG_NM).map		\
	-specs=nano.specs -specs=nosys.specs -Wl,--cref -Wl,--gc-sections 

ARFLAGS.cpp.STM32L4	+= -rscDv
LINTFLAGS.cpp.STM32L4	+= $(CFLAGS.cpp.STM32L4)
DOCFLAGS.cpp.STM32L4	+= 

elf: exe

bin: exe
	$(OBJCOPY.cpp.STM32L4) -O binary $(TGTDIR)/$(EXE_NM) $(TGTDIR)/$(PKG_NM).bin

hex: exe
	$(OBJCOPY.cpp.STM32L4) -O ihex $(TGTDIR)/$(EXE_NM) $(TGTDIR)/$(PKG_NM).hex

$(OBJDIR)/%.o	: %.S
	@mkdir -p $(@D)
	@echo $(CFLAGS) $(CFLAGS.cpp) $(CFLAGS.cpp.STM32L4) > $@.cflags ; 
	$(COMPILE.cpp.STM32L4) @$@.cflags $< 

$(OBJDIR)/%.o	: %.s
	@mkdir -p $(@D)
	@echo $(CFLAGS) $(CFLAGS.cpp) $(CFLAGS.cpp.STM32L4) > $@.cflags ; 
	$(COMPILE.cpp.STM32L4) @$@.cflags $< 

$(OBJDIR)/%.o	: %.cpp
	@mkdir -p $(@D)
	@echo $(CFLAGS) $(CFLAGS.cpp) $(CFLAGS.cpp.STM32L4) > $@.cflags ; 
	$(COMPILE.cpp.STM32L4) @$@.cflags $< 

$(OBJDIR)/%.i	: /%.cpp
	@mkdir -p $(@D)
	@echo -E $(CFLAGS) $(CFLAGS.cpp) $(CFLAGS.cpp.STM32L4) > $@.cflags ; 
	$(COMPILE.cpp.STM32L4) @$@.cflags $< 

$(OBJDIR)/%.ln	: %.cpp
	@mkdir -p $(@D)
	@echo $(LINTFLAGS) $(LINTFLAGS.cpp) $(LINTFLAGS.cpp.STM32L4) > $@.lintflags ; 
	$(LINT.cpp.STM32L4) @$@.lintflags $< 

$(DOCDIR)/%.html: $(SRCDIR)/%.cpp
	@mkdir -p $(@D)
	@echo $(DOCFLAGS) $(DOCFLAGS.cpp) $(DOCFLAGS.cpp.STM32L4) > $@.docflags ; 
	$(DOC.cpp.STM32L4) @$@.docflags $< 

.lib.cpp:	$(TGTDIR)/$(LIB_NM)
$(LIB_NM): $(TGTDIR)/$(LIB_NM)
$(TGTDIR)/$(LIB_NM): $(objs.cpp) $(EXTRA_OBJS)
	@mkdir -p $(@D)
	@echo 	$(ARFLAGS) $(ARFLAGS.cpp) $(ARFLAGS.cpp.STM32L4) > $@.arflags;
	$(AR.cpp.STM32L4) @$@.arflags $@ $^ 	

.exe.cpp:	$(TGTDIR)/$(EXE_NM)
$(EXE_NM): $(TGTDIR)/$(EXE_NM)
$(TGTDIR)/$(EXE_NM): $(objs.cpp) $(EXTRA_OBJS) 
	@mkdir -p $(@D)
	@echo $(LDFLAGS) $(LDFLAGS.cpp) $(LDFLAGS.cpp.STM32L4) > $@.ldflags;
	$(LD.cpp.STM32L4) @$@.ldflags $^ \
	    $(LIBS) $(LIBS.cpp) $(LIBS.cpp.STM32L4) 

flash:
	st-flash write $(TGTDIR)/$(PKG_NM).bin 0x8000000

