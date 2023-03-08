#***********************************************************************
#  $Version:$
#   Package	: xmt_cm
#   Synopsis	:
#   Purpose	: git wrappers & convenience aliases for shells with sh syntax.
#		Go ahead and customize them to your heart's content.
#		See std_gitalias.sh for an alternate version using git's "config alias".
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

alias gadd='git add -v --ignore-errors'						# add new or modified file to commit list
alias gstage=gadd											# synonym for gadd
alias gci='git commit --allow-empty'						# commit staged files & force comment
alias gdiff='git diff'										# show modified files not yet staged
alias gdiffs='git diff --staged'							# show files staged for next commit
alias gclone='function _gclone(){ git clone $@; };_gclone' 	# clone named remote repo
alias gco='function _gco(){ git checkout $@; };_gco' 		# update working copy of named file from repo
alias glogbr='git log --decorate --oneline'					# show branch history
alias glogpatch='git log --patch'							# show diffs in commit history 
alias glogfunc='function _glogfunc(){ git log -S $@; };_glogfunc' 	# show changes to function name
alias ghi='git log --pretty=format:"%h - %an, %ad : %s"'	# show concise commit history
alias grm='function _grm(){ git rm $@; };_grm' 				# remove named files from repo & working dir.
alias gmv='function _gmv(){ git mv $@; };_gmv' 				# move named file to new path in repo
alias greset='function _greset(){ git reset $@; };_greset' 	# unstage named files
alias gunstage=greset										# synonym for greset
alias gstatus='git status -s'								# list what's modified & staged
alias gstash='git stash -all'								# shelf everything in the working dir for later 
alias grls='git ls-remote origin'							# list differences from origin
alias gpull='git pull'										# pull & merge updates from origin
alias gpush='function _gpush(){ git push origin $@; };_gpush' # push updates to named branch on origin
alias gtag='function _gtag(){ git tag -a $@; };_gtag' 		# create named release tag for next commit
alias gstag='function _gstag(){ git tag -a -s $@; };_gstag' 	# create GPG-signed release tag for next commit
alias gvtag='function _gvtag(){ git tag -v $@; };_gvtag' 	# verify GPG-signed release tag 
alias gtags='git tag'										# list tags
alias gworkon='function _gworkon(){ git checkout $@; };_gworkon' 	# work on named branch
alias gbr='function _gbr(){ git checkout -b $@; };_gbr' 		# create & work on new named branch
alias glsbr='git branch -v'									# list all branches
alias grmbr='function _grmbr(){ git branch -d $@; };_grmbr' 	# remove named branch
alias gmerge='function _gmerge(){ git merge --no-ff $@; };_gmerge' 	# merge named branch into current branch
alias vmerge='git mergetool'								# run mergetool to resolve conflicts
