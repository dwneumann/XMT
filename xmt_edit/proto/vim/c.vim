"************************************************************************
"*  $Version:$
"*  standard vim mappings for C files
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
so $XMTEDIT/proto/vim/ctrl-X.vim
set wm=0 ai
ab #d 	#define
ab #e 	#endif
ab #f 	#ifdef
ab #i 	#include
ab #n 	#ifndef
ab #u 	#undef
ab #l	#ifdef lint
ab #D	<ESC>!!$XMTEDIT/bin/hdr -d -m diag<CR>
"************************************************************************
" In addition to standard ^X mappings:
" Command mode key mappings:            Insert mode key mappings:
"  ^X^A Alphebetize declarations        ()  expand parenthases
"  ^X=  format comment block            {^M expand block braces
"  ^X#  Renumber block of constants     ^Xc Comment
"  ^X^L List function synopses          []  expand brackets
"  ^Xf  function header
"  ^Xe  extern block of function declarations
"  ^Xx  Execute this line
"  <>   shift block left
"  ><   shift block right
"************************************************************************
map  <C-X>#	:'s,'e!$XMT/xmt_util/bin/renum.pl 3<CR>
map  <C-X><C-A>	:'s,'e !sort -b +1 -u<CR>
map  <C-X><C-L>	:1,$ !$XMTEDIT/bin/hdr -d -m c.synopsis<CR>
map  <C-X>e	:'s,'e s/..\(.*\)/extern \1;/<CR>
map  <C-X>f	ma]]mb:'a,'b !$XMTEDIT/bin/hdr -d -m c.func.ansi<CR>
map  <C-X>F	:0r !$XMTEDIT/bin/hdr %<CR>

imap <C-X>c	<CR>/*<CR> *  <CR>*/<CR><ESC>2-A
imap {<CR>	{<CR>}<ESC>O    

menu XMT.File\ Header<TAB><C-X>F			<C-X>F
menu XMT.Renumber\ Constants<TAB><C-X>#			<C-X>#
menu XMT.Alphebetize\ Declarations<TAB><C-X><C-A>	<C-X><C-A>
menu XMT.Function.Generate\ List<TAB><C-X><C-L>		<C-X><C-L>
menu XMT.Function.Generate\ Prototypes<TAB><C-X>e	<C-X>e
menu XMT.Function.ANSI\ Header<TAB><C-X>f		<C-X>f

set cscopetag 
set nocscopeverbose
"set cscopeprg=C:/cygwin32/bin/cscope.exe
set cscopeprg=/usr/bin/cscope
set nocscoperelative
function! AddCscopePath(dir)
    if filereadable( a:dir . "/cscope.out" )
	execute 'cs add '  a:dir . "/cscope.out"   
    endif
endfunction

let pkg = substitute( expand('%:p'), expand("$PROJECT") . '/', "", "" )
let pkg = substitute( pkg, '/.*$', "", "" )
" cscope kill -1
call AddCscopePath( "." )
call AddCscopePath( $PROJECT . '/' . pkg . '/src' )
call AddCscopePath( $PROJECT )

menu XMT.Cscope.Add\ cscope\ Path	:<C-U>call AddCscopePath( 
menu XMT.Cscope.Find\ Symbol\ Uses	:<C-U>cs find s <C-R>*<CR>
menu XMT.Cscope.Find\ Symbol\ Defn	:<C-U>cs find g <C-R>*<CR>
menu XMT.Cscope.Find\ Pattern		:<C-U>cs find e <C-R>*<CR>
menu XMT.Cscope.Find\ File		:<C-U>cs find f <C-R>*<CR>
menu XMT.Cscope.Find\ Callers\ of	:<C-U>cs find c <C-R>*<CR>
menu XMT.Cscope.Find\ Dependents\ of	:<C-U>cs find d <C-R>*<CR>
menu XMT.Cscope.Find\ Assignments\ to	:<C-U>cs find t <C-R>*<CR>
menu XMT.Cscope.Find\ Includers\ of	:<C-U>cs find i <C-R>*<CR>
