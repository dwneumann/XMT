#***********************************************************************
#   $Version:$
#   Package	: xmt_cm
#   Synopsis	:
#   Purpose	: git convenience aliases.
#		Go ahead and customize them to your heart's content.
#		See std_git.sh and std_git.csh for alternate versions using shell aliases.
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

git config alias.gadd	'git add -v --ignore-errors'	# add new or modified file to commit list
git config alias.gstage	 gadd				# synonym for gadd
git config alias.gci	'git commit'			# commit staged files & force comment
git config alias.gdiff	'git diff'			# show modified files not yet staged
git config alias.gdiffs	'git diff --staged'		# show files staged for next commit
git config alias.gclone	'git clone '			# clone named remote repo
git config alias.gco	'git checkout HEAD'		# update working copy of named file from repo
git config alias.glogbr	'git log --decorate --oneline'	# show branch history
git config alias.glogpatch	'git log --patch'	# show diffs in commit history 
git config alias.glogfunc	'git log -S '		# show changes to function name
git config alias.ghi	'git log --pretty=format:"%h - %an, %ad : %s"'	# show concise commit history
git config alias.grm 	'git rm '			# remove named files from repo & working dir.
git config alias.gmv	'git mv '			# move named file to new path in repo
git config alias.gunstage	'git reset '		# unstage named files
git config alias.gstatus	'git status -s'		# list what's modified & staged
git config alias.gstash	'git stash '			# shelf everything in the working dir for later 
git config alias.grls	'git ls-remote origin'		# list differences from origin
git config alias.gpull	'git pull'			# pull & merge updates from origin
git config alias.gpush	'git push origin --follow-tags'		# push updates to named branch on origin
git config alias.gtag	'git tag -a '			# create named release tag for next commit
git config alias.gstag	'git tag -s '			# create GPG-signed release tag for next commit
git config alias.gvtag	'git tag -v '			# verify GPG-signed release tag 
git config alias.gtags	'git tag'			# list tags
git config alias.gworkon 'git checkout'			# work on named branch
git config alias.gbr	'git checkout -b '		# create & work on new named branch
git config alias.glsbr	'git branch -v'			# list all branches
git config alias.grmbr	'git branch -d '		# remove named branch
git config alias.gmerge	'git merge --no-ff'		# merge named branch into current branch
git config alias.vmerge	'git mergetool'			# run mergetool to resolve conflicts
