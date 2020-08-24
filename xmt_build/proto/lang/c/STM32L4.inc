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

arch := STM32L4
#**********************************************************************
DOCER.$(lang).$(arch)	:= $(DOCER.$(lang))
LINTER.$(lang).$(arch)	:= $(LINTER.$(lang))
COMPILER.$(lang).$(arch):= $(COMPILER.$(lang))
LINKER.$(lang).$(arch)	:= $(LINKER.$(lang))
ARCHIVER.$(lang).$(arch):= $(ARCHIVER.$(lang))
OBJCOPY.$(lang).$(arch)	:= $(OBJCOPY.$(lang))
LIB_PFX.$(lang).$(arch)	:= $(LIB_PFX.$(lang))
LIB_SFX.$(lang).$(arch)	:= $(LIB_SFX.$(lang))
EXE_PFX.$(lang).$(arch)	:= $(EXE_PFX.$(lang))
EXE_SFX.$(lang).$(arch)	:= .elf

#**********************************************************************
# This is the place to define default flags and recipes
# that are specific to THIS target platform for THIS language.
#**********************************************************************

MCU	= -mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard 
CFLAGS.$(lang).$(arch)= -Wall -Wno-strict-aliasing -Wno-write-strings 		\
	-Wno-attributes -Wno-unused-function -Wno-unused-const-variable 			\
	-std=gnu99 -g -MMD -MP														\
	$(MCU) --specs=nano.specs --specs=nosys.specs 			 					\
	-DSTM32L4xx -DARM_MATH_CM4 -DCORE_M4 -mlittle-endian 						\
	-fstack-usage -fdata-sections -ffunction-sections -fmessage-length=0		\
	-fno-builtin -fsingle-precision-constant 

LDFLAGS.$(lang).$(lang)	= $(MCU) -Wl,-Map=$(TGTDIR)/$(PKG_NM).map				\
	-Wl,--cref -Wl,--gc-sections 												\
	--specs=nano.specs --specs=nosys.specs 
 			

LDFLAGS.$(lang).$(lang)	= $(MCU) -Wl,-Map=$(TGTDIR)/$(PKG_NM).map				\
	-Wl,--cref -Wl,--gc-sections 												\
	--specs=nano.specs --specs=nosys.specs 

ARFLAGS.$(lang).$(arch)		= 
LINTFLAGS.$(lang).$(arch)	= 
DOCFLAGS.$(lang).$(arch)	= 

.PHONY: bin.$(lang).$(arch)
bin.$(lang).$(arch):: exe.$(lang).$(arch)
	$(OBJCOPY.$(lang).$(arch)) -O binary $(TGTDIR)/$(EXE_NM) $(TGTDIR)/$(PKG_NM).bin

.PHONY: hex.$(lang).$(arch)
hex.$(lang).$(arch):: exe.$(lang).$(arch)
	$(OBJCOPY.$(lang).$(arch)) -O ihex $(TGTDIR)/$(EXE_NM) $(TGTDIR)/$(PKG_NM).hex

.PHONY: analyze.$(lang).$(arch) 
analyze.$(lang).$(arch) ::
	$(LINTER.$(LANGUAGE).$(ARCH))	\
		$(LINTFLAGS) $(LINTFLAGS.$(LANGUAGE)) $(LINTFLAGS.$(LANGUAGE).$(ARCH))  \
		$(srcs.$(lang)) $(hdrs.$(lang))

.PHONY: docs.$(lang).$(arch) 
docs.$(lang).$(arch) ::
	$(DOCER.$(LANGUAGE).$(ARCH))	\
		$(DOCFLAGS) $(DOCFLAGS.$(LANGUAGE)) $(DOCFLAGS.$(LANGUAGE).$(ARCH))

$(OBJDIR)/%.o	:: %.s
	@mkdir -p $(@D)
	@echo $(CFLAGS) $(CFLAGS.$(lang)) $(CFLAGS.$(lang).$(arch)) > $@.cflags ; 
	$(COMPILER.$(lang).$(arch)) @$@.cflags $< 

$(OBJDIR)/%.o	:: %.$(lang)
	@mkdir -p $(@D)
	@echo $(CFLAGS) $(CFLAGS.$(lang)) $(CFLAGS.$(lang).$(arch)) > $@.cflags ; 
	$(COMPILER.$(lang).$(arch)) @$@.cflags $< 

$(OBJDIR)/%.i	:: $(SRCDIR)/%.$(lang)
	@mkdir -p $(@D)
	@echo -E $(CFLAGS) $(CFLAGS.$(lang)) $(CFLAGS.$(lang).$(arch)) > $@.cflags ; 
	$(COMPILER.$(lang).$(arch)) @$@.cflags $< 

.PHONY: lib.$(lang).$(arch)
lib.$(lang).$(arch)::	$(TGTDIR)/$(LIB_NM)
$(LIB_NM):: $(TGTDIR)/$(LIB_NM)
$(TGTDIR)/$(LIB_NM):: $(objs.$(lang)) $(EXTRA_OBJS)
	@mkdir -p $(@D)
	@echo 	$(ARFLAGS) $(ARFLAGS.$(lang)) $(ARFLAGS.$(lang).$(arch)) > $@.arflags;
	$(ARCHIVER.$(lang).$(arch)) @$@.arflags $@ $^ 	

.PHONY: exe.$(lang).$(arch)
exe.$(lang).$(arch)::	$(TGTDIR)/$(EXE_NM)
$(EXE_NM):: $(TGTDIR)/$(EXE_NM)
$(TGTDIR)/$(EXE_NM):: $(objs.$(lang)) $(EXTRA_OBJS) 
	@mkdir -p $(@D)
	@echo $(LDFLAGS) $(LDFLAGS.$(lang)) $(LDFLAGS.$(lang).$(arch)) > $@.ldflags;
	$(LINKER.$(lang).$(arch)) @$@.ldflags $^ \
		$(LIBS) $(LIBS.$(lang)) $(LIBS.$(lang).$(arch)) 

.PHONY: stflash
stflash:: bin
	st-flash write $(TGTDIR)/$(PKG_NM).bin 0x8000000

