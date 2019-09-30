#************************************************************************
#*   Entity Id	: $Version:$
#*   Package	: xmt
#*   Synopsis	: source .cshrc
#*   Purpose	: 
#*	Sourcing this file from your ~/.cshrc causes any interactive csh 
#*	to inherit a standard XMT environment.
#*	For login shells it is executed BEFORE .login 
#*	Always source $XMT/.cshrc before any customizations.
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
#* standard stuff ...
#************************************************************************
if ( $?prompt ) then

    #********************************************************************
    #* include cshrc from individual XMT packages we want to enable
    #********************************************************************
    source $XMT/xmt_util/proto/cshrc 
    source $XMT/xmt_edit/proto/cshrc 
    source $XMT/xmt_build/proto/cshrc 
    source $XMT/xmt_cm/proto/cshrc
   # source $XMT/xmt_xhist/proto/cshrc
   # source $XMT/xmt_xtest/proto/cshrc
   # source $XMT/xmt_doc/proto/cshrc
   # source $XMT/xmt_defect/proto/cshrc
   # source $XMT/xmt_metrics/proto/cshrc
   # source $XMT/xmt_timesht/proto/cshrc

    #********************************************************************
    # remove duplicate entries from PATH & MANPATH
    #********************************************************************
    setenv  PATH    `echo $PATH | modenv -s`; 
    #setenv  MANPATH `echo $MANPATH | modenv` 
endif

#************************************************************************
#* local user stuff ...
#************************************************************************
if ( "$USER" == "xmt" ) then
    if (-r ~/.cshrc.xmt)		source ~/.cshrc.xmt
endif
