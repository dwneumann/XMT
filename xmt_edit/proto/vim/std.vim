"************************************************************************
"*  $Version:$
"*  standard vim environment
"*
"*  Copyright (c) 1998	Neumann & Associates Information Systems Inc.
"*  			legal.info@neumann-associates.com
"*  Licensed under the Apache License, Version 2.0 (the "License");
"*  you may not use this file except in compliance with the License.
"*  You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
"*  
"*  Unless required by applicable law or agreed to in writing, software
"*  distributed under the License is distributed on an "AS IS" BASIS,
"*  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
"*  See the License for the specific language governing permissions and
"*  limitations under the License. 
"************************************************************************

set ruler showmode 
set tabstop=8 shiftwidth=4 shiftround
set tags=tags,$PROJECT/tags
set softtabstop=0 
set more nocompatible notitle tildeop 
set backspace=indent,eol,start
set cpoptions=aABceFsu
set guioptions=afimgtr
set history=20
set mps=(:),{:},[:],<:>,`:'
set wildchar=<Tab> wildmode=longest,full
set lines=51 columns=100
set number
color xmt
syntax on
so $XMT/xmt_edit/proto/vim/ctrl-X.vim

"" define autocmds based upon suffix of base file type
au BufNewFile,BufRead *.txt		so $XMTEDIT/proto/vim/ctrl-X.vim
au BufNewFile,BufRead *.c,*.h		so $XMTEDIT/proto/vim/c.vim
au BufNewFile,BufRead *.sh		so $XMTEDIT/proto/vim/sh.vim
au BufNewFile,BufRead *.perl		so $XMTEDIT/proto/vim/perl.vim
au BufNewFile,BufRead *.html		so $XMTEDIT/proto/vim/html.vim
au BufNewFile,BufRead *.cpp,*.hpp	so $XMTEDIT/proto/vim/cpp.vim
au BufNewFile,BufRead *.java		so $XMTEDIT/proto/vim/java.vim

" map derived filetypes to base file types
au BufNewFile,BufRead *.l,*.y			doautocmd BufRead %.c
au BufNewFile,BufRead *.csh,*.ksh		doautocmd BufRead %.sh
au BufNewFile,BufRead *.pl,*.pm			doautocmd BufRead %.perl
au BufNewFile,BufRead *.cc,*.cxx,*.c++		doautocmd BufRead %.cpp
au BufNewFile,BufRead *.hh,*.hxx,*.h++		doautocmd BufRead %.cpp

" auto-create new files from template based upon file suffix
au BufNewFile *	0r !$XMTEDIT/bin/hdr %

" set window extra wide for editing makefile output
if @% =~# '.ERRS'
set lines=40 columns=130
so $XMT/xmt_edit/proto/vim/c.vim
endif

