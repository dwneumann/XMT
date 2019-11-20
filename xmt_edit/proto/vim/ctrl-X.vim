"************************************************************************
"*  $Version:$
"*  standard vim ^X mappings
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

"************************************************************************
" Command mode key mappings:            Insert mode key mappings:
"  ^X^A	                        	()  expand parenthases
"  ^X^B	Block operation			{^M expand block braces
"  ^X^P	Put block 			^Xc Comment
"  ^X^X	Cut block			^Xi indent C/C++ code block
"  ^X^Y	Yank block
"  ^X=  format comment block		^X+ goto named line of named file
"  ^Xx	Execute this line		^XE goto the source of this compiler error
"  ^P	Pop tagstack			^X< shift block left
"  ^T	Tag to				^X> shift block right
"  #	Alternate file
"  F	Format paragraph
"  ^XS	Spellcheck document
"  g	Global do
"************************************************************************
map #		:e#<CR>
map <C-P>	:pop<CR>
map <C-T>	:ta 
map <C-X><C-B>	:<C-U>'s,'e
map <C-X><C-P>	:put z<CR>
map <C-X><C-P>	:put z<CR>
map <C-X><C-X>	:<C-U>'s,'ed z<CR>
map <C-X><C-Y>	:<C-U>'s,'ey z<CR>
map <C-X>=	:<C-U>'s,'e !$XMTEDIT/bin/hdr -d -m comment<CR>
map <C-X>f	:doautocmd BufRead %.
map <C-X>i	:'s,'e !indent - \|unexpand --all<CR>
map <C-X>S	Go<ESC>!!spell -b %<CR>
map <C-X>+	c0:e! <ESC>f:s +<ESC>;C 0WdW$p<C-X>x
map <C-X>E	0f:s :e! +<ESC>f:C <ESC>0dW$p<C-X>x
map <C-X>x	:.y x<CR>@x
map <C-X><	mh%<%dd'hdd
map <C-X><	>%<<%<<%
map <> 		<%>>%>>%
map >< 		>%<<%<<%
map F		!} fmt -80 -c<CR>
map g		:%
map , 		:'s,'e
imap {}		{}<ESC>i
imap {<CR>	{<CR>}<ESC>O    
imap []		[]<ESC>i
imap ()		()<ESC>i

" we must ensure the XMT menu exists when we clear it.
menu XMT.dummy		*
aunmenu XMT
menu XMT.Set\ Filetype<TAB><C-X>f		<C-X>f
menu XMT.Find\ This\ Word<TAB>*			*
menu XMT.Reformat\ Comment<TAB><C-X>=		<C-X>=
menu XMT.Reformat\ Paragraph<TAB>F		F
menu XMT.Execute\ Line<TAB><C-X>x		<C-X>x
menu XMT.Goto\ Error<TAB><C-X>E			<C-X>E
menu XMT.Spell\ Check\ File<TAB><C-X>S		<C-X>S
menu XMT.Syntax\ On				:color xmt<CR>:syntax on<CR>
menu XMT.Syntax\ Dim\ Code			:XMTDimCode<CR>
menu XMT.Syntax\ Dim\ Comments			:XMTDimComments<CR>
menu XMT.Syntax\ No\ Dim			:XMTNoDim<CR>
