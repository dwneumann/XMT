#************************************************************************
#*   $Version:$
#*   Package	: xmt_build
#*   Synopsis	: included by $(XMTBUILD)/proto/lang/<language>/generic.inc
#*   Purpose	: 
#*              This Makefile segment adds architecture support to
#*              $(XMTBUILD)/proto/lang/<language>/generic.inc
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

#************************************************************************
# DO ALL VARIABLE ASSIGNMENTS HERE
#************************************************************************

#**********************************************************************
# define program paths...
#**********************************************************************
COMPILE.java.android	:= javac
LD.java.android	:= /bin/true
AR.java.android	:= jar
LINT.java.android	:= echo no lint installed for Java
DOC.java.android	:= javadoc

#**********************************************************************
# This is the place to define flags that are specific to THIS language
# when compiled for THIS architecture.
#**********************************************************************
CFLAGS.java.android     += -cp .:$(OBJDIR):$(ANDROID_HOME)/platforms/android-$(MIN_ANDROID_API)/android.jar
LDFLAGS.java.android	=
ARFLAGS.java.android	=
LINTFLAGS.java.android  =
DOCFLAGS.java.android	=
LIB_PFX.java.android	:= 
LIB_SFX.java.android	:= .jar
EXE_PFX.java.android	:= 
EXE_SFX.java.android	:= 

#************************************************************************
# DO TARGET RULE OVERRIDES HERE
#************************************************************************


