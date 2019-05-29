#************************************************************************
#*   $Version:$
#*   Package	: xmt_build
#*   Synopsis	: included by $(XMTBUILD)/proto/Makefile.top
#*   Purpose	: 
#*              This Makefile segment adds language support to
#*              $(XMTBUILD)/proto/Makefile.top
#*              It is intended to be included by that file only.
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

srcs.java	?= $(shell find $(SRCDIR)/ -type f -name '*.java')
objs.java	= $(patsubst $(SRCDIR)/%.java,$(OBJDIR)/%.class,$(srcs.java))
docs.java	= $(patsubst $(SRCDIR)/%.java,$(DOCDIR)/%.html,$(srcs.java))
#   MacOS bash leaves a leading slash so we need to strip it
#objs.java	= $(patsubst /%,%,$(objs.java))
#docs.java	= $(patsubst /%,%,$(docs.java))

hdrs.java	:= 
lnts.java	:= 

#**********************************************************************
# This is the place to define default flags that are common to ALL 
# supported architectures for THIS language.
#**********************************************************************
CFLAGS.java	+= -g -d $(OBJDIR) 
LDFLAGS.java	= 
ARFLAGS.java	= cf 
LINTFLAGS.java	= 
DOCFLAGS.java	= 

endif
ifdef do_rules
#************************************************************************
# DO TARGET RULE OVERRIDES HERE
#************************************************************************

#**********************************************************************
# rule for compiling java files with or without namespace heirarchy
#**********************************************************************
$(OBJDIR)/%.class: $(SRCDIR)/%.java
	mkdir -p $(dir $@);
	@echo	$(CFLAGS) $(CFLAGS.java) $(CFLAGS.java.$(ARCH)) > $@.cflags ;
	$(COMPILE.java.$(ARCH))	@$@.cflags $^ 

$(DOCDIR)/%.html: $(SRCDIR)/%.java
	cd $(DOCDIR); $(DOC.java.$(ARCH)) $(DOCFLAGS) $(DOCFLAGS.java) $(DOCFLAGS.java.$(ARCH)) $^

.lib.$(LANGUAGE):	$(TGTDIR)/$(LIB_NM)
.exe.$(LANGUAGE):	$(TGTDIR)/$(LIB_NM)

#**********************************************************************
# rule for creating jar archive 
#**********************************************************************
$(TGTDIR)/$(LIB_NM): $(objs.java) 
	( cd $(OBJDIR);  \
	  echo $(ARFLAGS) $(ARFLAGS.$(LANGUAGE)) $(ARFLAGS.$(LANGUAGE).$(ARCH)) > $(LIB_NM).arflags;\
	  $(AR.$(LANGUAGE).$(ARCH)) @$(LIB_NM).arflags $(LIB_NM) `find . -name '*.class'`;)
	  -/bin/mv $(OBJDIR)/$(LIB_NM) $(TGTDIR)/$(LIB_NM)


#************************************************************************
endif
