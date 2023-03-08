"************************************************************************
"* $Version:$
"* standard vim mappings for html files
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
so $XMT/xmt_edit/proto/vim/ctrl-X.vim
set wm=5 ai

"************************************************************************
" In addition to standard ^X mappings:
" Command mode key mappings:            Insert mode key mappings:
" ^Xb  Embolden word                    ^X+ Superscript
" ^Xi  Italicize word                   ^X- Subscript
" ^Xc  CODE environment                 ^Xc CODE environment
"                                       ^XE Enumerated list
"                                       ^XL Bulleted list
"                                       ^XT Tagged Table
"                                       ^Xb Embolden Word
"                                       ^Xf Footnote
"                                       ^Xi Italicize word
"                                       ^Xl list item
"                                       ^Xt Tagged table item
"************************************************************************
map  <C-X>b	lbi<B><ESC>Ea</B><ESC>
map  <C-X>i	lbi<I><ESC>Ea</I><ESC>
map  <C-X>c	i<CODE><ESC>Ea</CODE><ESC>
imap <C-X>+	<SUP></SUP><ESC>5hi
imap <C-X>-	<SUB></SUB><ESC>5hi
imap <C-X>E	<OL TYPE=1><CR></OL><CR><BR><ESC>-O<TAB>
imap <C-X>L	<UL><CR></UL><CR><BR><ESC>-O<TAB>
imap <C-X>T	<BR><CR><TABLE><CR></TABLE><ESC>O<TAB>
imap <C-X>b	<B></B><ESC>3hi
imap <C-X>c	<CODE></CODE><ESC>6hi
imap <C-X>f	<FT><CR></FT><CR><ESC>-O
imap <C-X>i	<I></I><ESC>3hi
imap <C-X>l	<LI></LI><ESC>4hi
imap <C-X>t	<TR VALIGN=TOP><CR></TR><ESC>O<TAB><TD></TD><ESC>4hi

menu XMT.Embolden\ Word<TAB><C-X>b		<C-X>b
menu XMT.Italicize\ Word<TAB><C-X>i		<C-X>i
menu XMT.CODE\ Environment<TAB><C-X>c		<C-X>c
imenu XMT.Superscript<TAB><C-X>+		<C-X>+
imenu XMT.Subscript<TAB><C-X>-			<C-X>-
imenu XMT.Enumerated\ List<TAB><C-X>E		<C-X>E
imenu XMT.Bulleted\ List<TAB><C-X>L		<C-X>L
imenu XMT.Table<TAB><C-X>T			<C-X>T
imenu XMT.Embolden\ Word<TAB><C-X>b		<C-X>b
imenu XMT.CODE\ Environment<TAB><C-X>c		<C-X>c
imenu XMT.Footnote<TAB><C-X>f			<C-X>f
imenu XMT.Italicize\ Word<TAB><C-X>i		<C-X>i
imenu XMT.List\ Item<TAB><C-X>l			<C-X>l
imenu XMT.Table\ Item<TAB><C-X>t		<C-X>t
