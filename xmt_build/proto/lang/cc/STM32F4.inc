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

CMSIS	= $(STM32_FW)/Libraries/CMSIS

#**********************************************************************
# define program paths...
#**********************************************************************
GNUROOT			:= arm-none-eabi
COMPILE.cc.STM32F4	:= $(GNUROOT)-gcc
LD.cc.STM32F4		:= $(GNUROOT)-gcc
AR.cc.STM32F4		:= $(GNUROOT)-ar
DOC.cc.STM32F4		:= $(XMTBUILD)/bin/srcdoc 
LINT.cc.STM32F4		:= echo lint not installed
OBJCOPY.cc.STM32F4	:= $(GNUROOT)-objcopy
LIB_PFX.cc.STM32F4	:= lib
LIB_SFX.cc.STM32F4	:= .a
EXE_PFX.cc.STM32F4	:= 
EXE_SFX.cc.STM32F4	:= .elf

#**********************************************************************
# This is the place to define default flags that are specific to THIS 
# platform and THIS language.
#**********************************************************************
CFLAGS.cc.STM32F4 += -Wall -mlittle-endian -mthumb -mcpu=cortex-m4 	\
		    -mthumb-interwork -mfloat-abi=hard -mfpu=fpv4-sp-d16 	

LDFLAGS.cc.STM32F4	+= $(CFLAGS.cc.STM32F4) 
ARFLAGS.cc.STM32F4	+= -rscDv
LINTFLAGS.cc.STM32F4	+= $(CFLAGS.cc.STM32F4)
DOCFLAGS.cc.STM32F4	+= 

bin: exe
	$(OBJCOPY.cc.STM32F4) -O binary $(TGTDIR)/$(EXE_NM) $(TGTDIR)/$(PKG_NM).bin

hex: exe
	$(OBJCOPY.cc.STM32F4) -O ihex $(TGTDIR)/$(EXE_NM) $(TGTDIR)/$(PKG_NM).hex
