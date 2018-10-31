#***********************************************************************
#   $Version:$
#   Package	: xmt_cm
#   Synopsis	:
#   Purpose	: RCS wrappers & convenience aliases for shells with csh syntax.
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

setenv RCSINIT		'-zLT'			# RCS default options
alias sc	'set f="\!*";rcs -i -L -t-"" $f; sd $f'
alias sd	'$XMTCM/bin/commit -u'
alias sda	'set f="`st`";sd $f'
alias sde	'$XMTCM/bin/commit -l'
alias sdea	'set f="`st`";sde $f'
alias sdf	rcsdiff
alias sdff	rcsdiff
alias se	'co -l'
alias sea	'set f="`sls`"; se $f'
alias sg	'co -u'
alias sga	'set f="`sls`"; sg $f'
alias si	'rlog -L -R -l RCS/* | sed -e "s/.*\///" -e "s/,v//"'
alias sls	'ls RCS/*,v | sed -e "s/.*\///" -e "s/,v//"'
alias sp	rlog
alias srm 	'set f="\!*";/bin/rm -i RCS/{`echo $f|/bin/tr -s " " ,`},v $f'
alias st	'rlog -L -R -l$USER RCS/* | sed -e "s/.*\///" -e "s/,v//"'
alias sv	'set f="\!*";se $f; vi $f'
alias sw	ident
alias sx	'set f="\!*";rcs -u $f; /bin/chmod -f a-w $f; sg $f'
alias sxa	'set f="`st`"; rcs -u $f; /bin/chmod -f a-w $f; sg $f'
alias vst	'vi `st`'
