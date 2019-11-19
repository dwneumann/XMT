"************************************************************************
"*  $Version:$
"* standard vim mappings for LaTeX files
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
set wm=10 ai 
hi Comment		term=bold guifg=fg gui=bold
hi texSection		term=bold guifg=fg gui=bold
hi texSectionMarker	term=bold guifg=fg gui=bold

map <C-X>S  Go<ESC>!!sed<Space>'s:\\:\\\\:g' %\|spell -b<CR>
"************************************************************************
" Command mode key mappings:		Insert mode key mappings:
" ^X_  Underline line                   ^X+ Text mode Superscript
" ^Xb  Embolden word                    ^X- Text mode Subscript
" ^Xe  Emphasize word                   ^X_ Text mode underline
"                                       ^XD Description environment
"                                       ^XE Enumerated list environment
"                                       ^XL Bulleted list environment
"                                       ^XT Table environment
"                                       ^XV Verbatim environment
"                                       ^Xb Embolden Word
"                                       ^Xf Footnote
"                                       ^Xe Emphasize word
"                                       ^Xi list item
"************************************************************************
map  <C-X>_	lbi\underline{<ESC>Ea}<ESC>
map  <C-X>b	lbi\textbf{<ESC>Ea}<ESC>
map  <C-X>e	lbi\emph{<ESC>Ea}<ESC>
imap <C-X>+	\raisebox{0.6ex}{}
imap <C-X>-	\raisebox{-0.6ex}{}
imap <C-X>D	\begin{description}<CR>\end{description}<CR><ESC>-O<TAB>\item []
imap <C-X>E	\begin{enumerate}<CR>\end{enumerate}<CR><ESC>-O<TAB>\item 
imap <C-X>L	\begin{itemize}<CR>\end{itemize}<CR><ESC>-O<TAB>\item 
imap <C-X>T	<ESC>!!$XMTEDIT/bin/hdr -m tex.table<CR>
imap <C-X>V	\begin{verbatim}<CR>\end{verbatim}<CR><ESC>-O
imap <C-X>b	\textbf{}
imap <C-X>c	%
imap <C-X>e	\emph{}
imap <C-X>f	\footnote{}
imap <C-X>i	\item 

menu XMT.Underline\ Word<TAB><C-X>_		<C-X>_
menu XMT.Embolden\ Word<TAB><C-X>b		<C-X>b
menu XMT.Emphasize\ Word<TAB><C-X>e		<C-X>e
imenu XMT.Superscript<TAB><C-X>+		<C-X>+
imenu XMT.Subscript<TAB><C-X>-			<C-X>-
imenu XMT.Description\ List<TAB><C-X>D		<C-X>D
imenu XMT.Enumerated\ List<TAB><C-X>E		<C-X>E
imenu XMT.Bulleted\ List<TAB><C-X>L		<C-X>L
imenu XMT.Table<TAB><C-X>T			<C-X>T
imenu XMT.Verbatim<TAB><C-X>V			<C-X>V
imenu XMT.Embolden\ Word<TAB><C-X>b		<C-X>b
imenu XMT.Emphasize\ Word<TAB><C-X>e		<C-X>e
imenu XMT.Footnote<TAB><C-X>f			<C-X>f
imenu XMT.List\ Item<TAB><C-X>i			<C-X>i
