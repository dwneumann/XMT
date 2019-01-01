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
COMPILE.c.STM32L4	:= $(GNUROOT)-gcc
LD.c.STM32L4		:= $(GNUROOT)-gcc
AR.c.STM32L4		:= $(GNUROOT)-ar
DOC.c.STM32L4		:= $(XMTBUILD)/bin/srcdoc 
LINT.c.STM32L4		:= echo lint not installed
OBJCOPY.c.STM32L4	:= $(GNUROOT)-objcopy
LIB_PFX.c.STM32L4	:= lib
LIB_SFX.c.STM32L4	:= .a
EXE_PFX.c.STM32L4	:= 
EXE_SFX.c.STM32L4	:= .elf

#**********************************************************************
# This is the place to define default flags and recipes
# that are always true for THIS target platform for THIS language.
#**********************************************************************
CFLAGS.c.STM32L4 += -Wall -Wno-unused-const-variable -mlittle-endian -mthumb	\
	-mcpu=cortex-m4 -mthumb-interwork -mfloat-abi=hard -mfpu=fpv4-sp-d16	\
	-fdata-sections -ffunction-sections 					\
	-DUSE_HAL_DRIVER -DSTM32L476xx -DARM_MATH_CM4 -D__FPU_PRESENT=1 	

LDFLAGS.c.STM32L4	+= $(CFLAGS.c.STM32L4) -Wl,-Map=$(TGTDIR)/$(PKG_NM).map \
	-Wl,--cref -Wl,--gc-sections --specs=nano.specs -lc -lm 

ARFLAGS.c.STM32L4	+= -rscDv
LINTFLAGS.c.STM32L4	+= $(CFLAGS.c.STM32L4)
DOCFLAGS.c.STM32L4	+= 

bin: exe
	$(OBJCOPY.c.STM32L4) -O binary $(TGTDIR)/$(EXE_NM) $(TGTDIR)/$(PKG_NM).bin

hex: exe
	$(OBJCOPY.c.STM32L4) -O ihex $(TGTDIR)/$(EXE_NM) $(TGTDIR)/$(PKG_NM).hex
