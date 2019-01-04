#************************************************************************
#*   Entity Id	: $Version:$
#*   Package	: xmt
#*   Synopsis	: source .bashrc
#*   Purpose	: 
#*	Sourcing this file from your ~/.bashrc causes any interactive sh 
#*	to inherit a standard XMT environment.
#*	Always source $XMT/.bashrc before any customizations.
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
if [[ $- == *i* ]]; then

    #********************************************************************
    #* include cshrc from individual XMT packages we want to enable
    #********************************************************************
    source $XMT/xmt_util/proto/bashrc 
    source $XMT/xmt_edit/proto/bashrc 
    source $XMT/xmt_build/proto/bashrc 
    source $XMT/xmt_cm/proto/bashrc
    source $XMT/xmt_xhist/proto/bashrc
    source $XMT/xmt_wbtest/proto/bashrc
#    source $XMT/xmt_doc/proto/bashrc
#    source $XMT/xmt_defect/proto/bashrc
#    source $XMT/xmt_metrics/proto/bashrc
#    source $XMT/xmt_timesht/proto/bashrc

    #********************************************************************
    # remove duplicate entries from PATH & MANPATH
    #********************************************************************
    #setenv  PATH=    `echo $PATH |  modenv`; 
    #setenv  MANPATH= `echo $MANPATH | modenv` 
fi
