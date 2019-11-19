"************************************************************************
"*  $Version:$
"*  standard ex/vi mappings for sh/csh/ksh files
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
so $XMTEDIT/proto/vim/c.vim

"************************************************************************
" In addition to standard ^X mappings:
" Command mode key mappings:            Insert mode key mappings:
"************************************************************************
"************************************************************************
" unmap mappings inherited from c.vim but not used in Perl
"************************************************************************
unmap  <C-X>#
unmap  <C-X><C-A>
unmap  <C-X><C-L>
unmap  <C-X>e
unmap  <C-X>f

unmenu XMT.Renumber\ Constants
unmenu XMT.Alphebetize\ Declarations
unmenu XMT.Function
unmenu XMT.Cscope

"************************************************************************
" remap these differently than c.vim
"************************************************************************
imap <C-X>c	<CR>#<CR># <CR>#<ESC>-A
