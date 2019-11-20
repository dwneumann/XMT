"************************************************************************
"* $Version:$
"* standard vim mappings for nroff/troff files
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
"************************************************************************
" In addition to standard ^X mappings:
" Command mode key mappings:		Insert mode key mappings:
" ^Xb  Embolden word                    ^X+ Superscript
" ^Xi  Italisize word                   ^X- Subscript
"                                       ^XE Enumerated list
"                                       ^XL Bulleted list
"                                       ^XT Tagged Table
"                                       ^Xb Embolden Word
"                                       ^Xe Enumerated item
"                                       ^Xf Footnote
"                                       ^Xi Italicize word
"                                       ^Xl Bulleted list item
"                                       ^Xt Tagged table item
"                                       --  em dash
"************************************************************************
set wm=10 noai
set paragraphs=pplpnpbpsp sections=NHSHH\ HUnhshsx

map  <C-X>b	lbi\fB<ESC>Ea\fP<ESC>
map  <C-X>i	lbi\fI<ESC>Ea\fP<ESC>
imap --		\(em
imap <C-X>+	\*{\*}<ESC>2hi
imap <C-X>-	\*<\*><ESC>2hi
imap <C-X>E	.in +0.5i<CR>.in -0.5i<CR>.sp<ESC>-O.nr EN 0 1<CR>.af EN i<CR>
imap <C-X>L	.in +0.5i<CR>.in -0.5i<CR>.sp<ESC>-O
imap <C-X>T	.sp<CR>.TS<CR>center;<CR>lBw(2i) lw(3i).<CR>.TE<ESC>O
imap <C-X>b	\fB\fP<ESC>2hi
imap <C-X>e	.sp<CR>.ti -0.5i<CR>\fI\n+(EN)\fP<C-I>
imap <C-X>f	\**<CR>.(f<CR>\**\ <CR>.)f<CR><ESC>2-A
imap <C-X>i	\fI\fP<ESC>2hi
imap <C-X>l	.sp<CR>.ti -\w'\(bu\ 'u<CR>\(bu\ 
imap <C-X>t	x<C-I>T{<CR>T}<CR>.sp<ESC>2-s

menu XMT.Italicize\ Word<TAB><C-X>i		<C-X>i
menu XMT.Embolden\ Word<TAB><C-X>b		<C-X>b
imenu XMT.Superscript<TAB><C-X>+		<C-X>+
imenu XMT.Subscript<TAB><C-X>-			<C-X>-
imenu XMT.Enumerated\ List<TAB><C-X>E		<C-X>E
imenu XMT.Bulleted\ List<TAB><C-X>L		<C-X>L
imenu XMT.Table<TAB><C-X>T			<C-X>T
imenu XMT.Embolden\ Word<TAB><C-X>b		<C-X>b
imenu XMT.Enumerated\ Item<TAB><C-X>e		<C-X>e
imenu XMT.Footnote<TAB><C-X>f			<C-X>f
imenu XMT.Italicize\ Word<TAB><C-X>i		<C-X>i
imenu XMT.Bulleted\ Item<TAB><C-X>l		<C-X>l
imenu XMT.Table\ Item<TAB><C-X>t		<C-X>t
