#***********************************************************************
#   $Version:$
#   Package	: xmt_cm
#   Synopsis	:
#   Purpose	: mercurial wrappers & convenience aliases for shells with csh syntax.
#		Go ahead and customize them to your heart's content.
#
#  Copyright (c) 2018	Visionary Research Inc.
#  			legal@visionary-research.com
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

alias hadd='hg add'										# add new or modified files to repository
alias haddrm='hg addremove'								# add new & delete missing files to repository
alias hblame='hg blame'									# list who/when changes were made to a file
alias hbr='function _hbr(){ hg bookmark $@; };_hbr'		# tag working set as named branch
alias hcat='function _hcat(){ hg cat $@; };_hcat'			# cat named file as at given revision
alias hci='hg commit'									# commit staged files 
alias hclone='function _hclone(){ hg clone $@; };_hclone'		# clone named remote repo
alias hco='function _hco(){ hg update $@; };_hco'			# update working copy of named file from repo
alias hgraft='function _hgraft(){ hg graft --log -r $@; };_hgraft'	# cherry pick specified rev from other branches into current working set
alias hgrep='function _hgrep(){ hg grep $@; };_hgrep'		# search revision history for a pattern in specified files
alias hdiff='hg diff'									# show modified files not yet staged
alias hheads='hg heads'									# show head revisions of all branches
alias hhi="hg log| sed '/^files:/ s/  */\n\t/g'"		# show concise commit history
alias hid='hg identify --id'							# show build identifier for working set
alias hlogbr='hg log --graph'							# show branch history
alias hlsbr='hg branches'								# list all branches
alias hmerge='function _hmerge(){ hg merge -r $@; };_hmerge'	# merge listed revision into working set
alias hmv='function _hmv(){ hg mv $@; };_hmv'				# move named file to new path in repo
alias hpull='function _hpull(){ hg pull $@; };_hpull'		# pull updates from named repo
alias hpush='function _hpush(){ hg push $@; };_hpush'		# push updates to named repo
alias hrevert='function _hrevert(){ hg revert $@; };_hrevert'		# restore files to the state of another revision
alias hrm='function _hrm(){ hg forget $@; };_hrm'		# remove named files from this branch of repo
alias hstatus='hg status'								# list what's modified 
alias htag='function _htag(){ hg tag $@; };_htag'			# create named tag for next commit
alias htags='hg tags'									# list tags
alias hworkon='function _hworkon(){ hg update -r $@; };_hworkon'	# checkout named revision/branch
alias vmerge='hg mergetool'								# run mergetool to resolve conflicts
