#***********************************************************************
#   $Version:$
#   Package	: xmt_cm
#   Synopsis	:
#   Purpose	: CVS wrappers & convenience aliases for shells with csh syntax.
#		Go ahead and customize them to your heart's content.
#
#  Copyright (c) 1998	Neumann & Associates Information Systems Inc.
#  			legal.info@neumann-associates.com
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
#  
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License. 
#***********************************************************************

alias sc	'cvs add'
alias sd	'cvs commit'
alias sda	'set f="`st`";sd $f'
alias sde	'$XMTCM/bin/commit -l'
alias sdea	'set f="`st`";sde $f'
alias sdf	'cvs diff'
alias sdff	'cvs diff'
alias se	'cvs edit'
alias sea	'set f="`sls`"; se $f'
alias sg	'cvs checkout'
alias sga	'cvs checkout'
alias sp	'cvs history -e -a'
alias srm 	'cvs remove'
alias sx	'cvs unedit'
alias sxa	'cvs release'
alias sv	'set f="\!*";se $f; vi $f'
alias vst	'vi `st`'
alias si	'cvs editors . | sed "s/[	 ].*//"'
alias sls	'ls RCS/*,v | sed -e "s/.*\///" -e "s/,v//"'
alias st	'cvs editors . | grep $USER | sed "s/[	 ].*//"'
