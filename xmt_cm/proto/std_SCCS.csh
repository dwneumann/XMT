#***********************************************************************
#   $Version:$
#   Package	: xmt_cm
#   Synopsis	:
#   Purpose	: SCCS wrappers & convenience aliases for shells with csh syntax.
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
#************************************************************************

alias sc	'set f="\!*";sccs create $f'
alias sd	'set f="\!*";$XMTCM/bin/commit -u $f'
alias sda	'set f="`st`"; sd $f'
alias sde	'set f="\!*";$XMTCM/bin/commit -l $f'
alias sdea	'set f="`st`";sde $f'
alias sdf	'sccs diffs'
alias sdff	'sccs sccsdiff'
alias se	'sccs edit'
alias sea	'set f="`sls`"; se $f'
alias sfix	'sccs fix'
alias sg	'sccs get'
alias sga	'set f="`sls`"; sg $f'
alias si	'sccs info | sed -e "s/.*\///" -e "s/,v//"'
alias sls	'ls SCCS/s.* | sed "s/.*\/s.//" `'
alias sp	'sccs prt'
alias srm 	'set f="\!*";/bin/rm -i SCCS/[sp].{`echo $f|/bin/tr -s " " ,`} $f'
alias st	'sccs tell -u $USER'
alias sv	'set f="\!*";se $f; vi $f'
alias sw	'sccs what'
alias sx	'set f="\!*";sccs unedit $f'
alias sxa	'set f="`st`"; sx $f'
alias vst	'vi `st`'
