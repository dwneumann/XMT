"************************************************************************
"*   Entity Id	: $Version:$
"*   Package	: ~xmt
"*   Purpose	: vim & gvim initialization commands for XMT extensions.
"*
"*  Copyright 2018 Visionary Research Inc.  
"*  			legal@visionary-research.com
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

set nocompatible
so $XMTEDIT/proto/vim/std.vim
set nohlsearch
auto BufEnter * let &titlestring = expand("%:p")
let $TMP="/tmp"
set magic
set cscoperelative
set title 
set tabstop=4
set shiftwidth=4

" shell escapes should run bash open in the working directory
" Without --login, Cygwin won't mount some directories such as /usr/bin/
" # this works for both console vim & gvim, with or without named file
"set shell=C:/cygwin32/bin/bash.exe
set shell=/bin/bash
set shellcmdflag=-c\ 
set noshelltemp
set shellslash

" for gvim, set fontsize
set guifont=Monospace\ 9

