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
AXSDB			:= "c:\Programs\AXSEM\AXSDB"
CCROOT			:= "c:\Programs\SDCC"
COMPILE.c.AX8052	:= sdcc
LD.c.AX8052		:= sdcc
AR.c.AX8052		:= sdcclib
DOC.c.AX8052		:= $(XMTBUILD)/bin/srcdoc 
LINT.c.AX8052		:= echo lint not installed
OBJCOPY.c.AX8052	:= 
LIB_PFX.c.AX8052	:= lib
LIB_SFX.c.AX8052	:= .lib
EXE_PFX.c.AX8052	:= 
EXE_SFX.c.AX8052	:= .hex

# SDCC doesn't grok .o file extension.  Must redefine rules & variables to use .rel
objs.c	= $(patsubst $(SRCDIR)/%.c,$(OBJDIR)/%.rel,$(srcs.c))

#**********************************************************************
# This is the place to define default flags that are specific to THIS 
# platform and THIS language.
#**********************************************************************

#*** model-small-stack-auto
#SMALL_STACK_AUTO	= $(DOSPROJECT)/AX5043/small-stack-auto
#SYS_INCLUDES.c.AX8052 = \
#		   -I$(CCROOT)/include 				\
#		   -I$(SMALL_STACK_AUTO)/libmf/src		\
#		   -I$(SMALL_STACK_AUTO)/libaxdvk2/src		\
#		   -I$(SMALL_STACK_AUTO)/libax5043/src	
#CFLAGS.c.AX8052 += -mmcs51 --verbose --model-small --stack-auto -DRADIO=5043 $(SYS_INCLUDES.c.AX8052)
#LDFLAGS.c.AX8052 += -mmcs51 --verbose --model-small --stack-auto -muwx -M 	\
#		    --xram-size 8192 --iram-size 256 --code-size 64512 		\
#		    --code-loc 0x0000 --xram-loc 0x0000 --data-loc 0x08 	\
#		    -L$(CCROOT)/lib 						\
#		    -L$(AXSDB)/libreent/sdcc 					\
#		    -L$(SMALL_STACK_AUTO)/libaxdvk2/tgt/AX8052			\
#		    -L$(SMALL_STACK_AUTO)/libmf/tgt/AX8052			\
#		    -L$(SMALL_STACK_AUTO)/libax5043/tgt/AX8052			\
#		    -l libmf_small_stack_auto 					\
#		    -l libaxdvk2_small_stack_auto				\
#		    -l libax5043_small_stack_auto				

#*** model-small
SYS_INCLUDES.c.AX8052 = \
		   -I$(CCROOT)/include 				\
		   -I$(AXSDB)/libmf/include			\
		   -I$(AXSDB)/libaxdvk2/include			\
		   -I$(AXSDB)/libax5043/include	
CFLAGS.c.AX8052 += -mmcs51 --verbose --model-small -DRADIO=5043 $(SYS_INCLUDES.c.AX8052)
LDFLAGS.c.AX8052 += -mmcs51 --verbose --model-small -muwx -M 			\
		    --xram-size 8192 --iram-size 256 --code-size 64512 		\
		    --code-loc 0x0000 --xram-loc 0x0000 --data-loc 0x08 	\
		    -L$(CCROOT)/lib 						\
		    -L$(AXSDB)/libreent/sdcc 					\
		    -L$(AXSDB)/libaxdvk2/sdcc 					\
		    -L$(AXSDB)/libmf/sdcc 					\
		    -L$(AXSDB)/libax5043/sdcc 					\
		    -l libmf 							\
		    -l libaxdvk2						\
		    -l libax5043				


$(OBJDIR)/%.rel	: $(SRCDIR)/%.s
	$(COMPILE.c.AX8052) $(CFLAGS) $(CFLAGS.c) $(CFLAGS.c.AX8052) -c $< -o $@

$(OBJDIR)/%.rel	: $(SRCDIR)/%.c
	$(COMPILE.c.AX8052) $(CFLAGS) $(CFLAGS.c) $(CFLAGS.c.AX8052) -c $< -o $@

bin: exe
hex: exe

flash:  $(TGTDIR)/$(EXE_NM)
	axsdb --flashprog $(TGTDIR)/$(EXE_NM)


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


