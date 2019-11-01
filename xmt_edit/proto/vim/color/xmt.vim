" Name: XMT Colorscheme
" adapted from https://github.com/robertmeta/nofrils-dark

hi clear
if exists("syntax_on")
    syntax reset
endif

let g:colors_name = "xmt"
set background=dark

" Baseline
hi Normal term=NONE cterm=NONE ctermfg=White ctermbg=Black gui=NONE guifg=White guibg=Black

" Faded
hi ColorColumn term=NONE cterm=NONE ctermfg=NONE ctermbg=236 gui=NONE guifg=NONE guibg=#303030
hi Comment term=NONE cterm=NONE ctermfg=DarkCyan ctermbg=NONE gui=NONE guifg=DarkCyan guibg=NONE
hi FoldColumn term=NONE cterm=NONE ctermfg=LightGrey ctermbg=NONE gui=NONE guifg=LightGrey guibg=NONE
hi Folded term=NONE cterm=NONE ctermfg=LightGrey ctermbg=NONE gui=NONE guifg=LightGrey guibg=NONE
hi LineNr term=NONE cterm=NONE ctermfg=DarkCyan ctermbg=bg gui=NONE guifg=DarkCyan guibg=bg
hi NonText term=NONE cterm=NONE ctermfg=LightGrey ctermbg=NONE gui=NONE guifg=LightGrey guibg=NONE
hi SignColumn term=NONE cterm=NONE ctermfg=LightGrey ctermbg=NONE gui=NONE guifg=LightGrey guibg=NONE
hi SpecialKey term=NONE cterm=NONE ctermfg=LightGrey ctermbg=NONE gui=NONE guifg=LightGrey guibg=NONE
hi StatusLineNC term=NONE cterm=NONE ctermfg=fg ctermbg=LightGrey gui=NONE guifg=fg guibg=LightGrey
hi VertSplit term=NONE cterm=NONE ctermfg=Black ctermbg=LightGrey gui=NONE guifg=Black guibg=LightGrey

" Highlighted
hi CursorColumn term=NONE cterm=NONE ctermfg=NONE ctermbg=236 gui=NONE guifg=NONE guibg=#303030
hi CursorIM term=NONE cterm=NONE ctermfg=Black ctermbg=4 gui=NONE guifg=Black guibg=#00FFFF
hi CursorLineNr term=NONE cterm=NONE ctermfg=NONE ctermbg=Black gui=NONE guifg=NONE guibg=Black
hi CursorLine term=NONE cterm=NONE ctermfg=NONE ctermbg=236 gui=NONE guifg=NONE guibg=#303030
hi Cursor term=NONE cterm=NONE ctermfg=Black ctermbg=4 gui=NONE guifg=Black guibg=#00FFFF
hi Directory term=NONE cterm=NONE ctermfg=69 ctermbg=NONE gui=NONE guifg=#5F87FF guibg=NONE
hi ErrorMsg term=NONE cterm=NONE ctermfg=fg ctermbg=52 gui=NONE guifg=fg guibg=#5F0000
hi Error term=NONE cterm=NONE ctermfg=fg ctermbg=52 gui=NONE guifg=fg guibg=#5F0000
hi IncSearch term=NONE cterm=NONE ctermfg=Black ctermbg=green gui=NONE guifg=Black guibg=green
hi MatchParen term=NONE cterm=NONE ctermfg=White ctermbg=DarkCyan gui=NONE guifg=White guibg=DarkCyan
hi ModeMsg term=NONE cterm=NONE ctermfg=69 ctermbg=NONE gui=NONE guifg=#5F87FF guibg=NONE
hi MoreMsg term=NONE cterm=NONE ctermfg=69 ctermbg=NONE gui=NONE guifg=#5F87FF guibg=NONE
hi PmenuSel term=NONE cterm=NONE ctermfg=Black ctermbg=13 gui=NONE guifg=Black guibg=#FF00FF
hi Question term=NONE cterm=NONE ctermfg=69 ctermbg=NONE gui=NONE guifg=#5F87FF guibg=NONE
hi Search term=NONE cterm=NONE ctermfg=Black ctermbg=6 gui=NONE guifg=Black guibg=#00CDCD
hi StatusLine term=NONE cterm=NONE ctermfg=Black ctermbg=fg gui=NONE guifg=Black guibg=fg
hi Todo term=NONE cterm=NONE ctermfg=Cyan ctermbg=NONE gui=NONE guifg=Cyan guibg=Black
hi UserCode term=NONE cterm=NONE ctermfg=Cyan ctermbg=NONE gui=NONE guifg=Cyan guibg=Black
hi WarningMsg term=NONE cterm=NONE ctermfg=fg ctermbg=52 gui=NONE guifg=fg guibg=#5F0000
hi WildMenu term=NONE cterm=NONE ctermfg=fg ctermbg=Black gui=NONE guifg=fg guibg=Black

" Reversed
hi PmenuSbar term=reverse cterm=reverse ctermfg=NONE ctermbg=NONE gui=reverse guifg=NONE guibg=NONE
hi Pmenu term=reverse cterm=reverse ctermfg=NONE ctermbg=NONE gui=reverse guifg=NONE guibg=NONE
hi PmenuThumb term=reverse cterm=reverse ctermfg=NONE ctermbg=NONE gui=reverse guifg=NONE guibg=NONE
hi TabLineSel term=reverse cterm=reverse ctermfg=NONE ctermbg=NONE gui=reverse guifg=NONE guibg=NONE
hi Visual term=reverse cterm=reverse ctermfg=NONE ctermbg=NONE gui=reverse guifg=NONE guibg=NONE
hi VisualNOS term=reverse,underline cterm=reverse,underline ctermfg=NONE ctermbg=NONE gui=reverse,underline guifg=NONE guibg=NONE

" Diff
hi DiffAdd term=NONE cterm=NONE ctermfg=2 ctermbg=NONE gui=NONE guifg=#008000 guibg=NONE
hi DiffChange term=NONE cterm=NONE ctermfg=3 ctermbg=NONE gui=NONE guifg=#808000 guibg=NONE
hi DiffDelete term=NONE cterm=NONE ctermfg=1 ctermbg=NONE gui=NONE guifg=#800000 guibg=NONE
hi DiffText term=NONE cterm=NONE ctermfg=4 ctermbg=NONE gui=NONE guifg=#000080 guibg=NONE

" Spell
hi SpellBad term=underline cterm=underline ctermfg=13 ctermbg=NONE gui=underline guifg=#FF00FF guibg=NONE
hi SpellCap term=underline cterm=underline ctermfg=13 ctermbg=NONE gui=underline guifg=#FF00FF guibg=NONE
hi SpellLocal term=underline cterm=underline ctermfg=13 ctermbg=NONE gui=underline guifg=#FF00FF guibg=NONE
hi SpellRare term=underline cterm=underline ctermfg=13 ctermbg=NONE gui=underline guifg=#FF00FF guibg=NONE

" Vim Features
hi Menu term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi Scrollbar term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi TabLineFill term=NONE cterm=NONE ctermfg=fg ctermbg=LightGrey gui=NONE guifg=fg guibg=LightGrey
hi TabLine term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi Tooltip term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE

" Syntax Highlighting (or lack of)
hi Boolean term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi Character term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi Conceal term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi Conditional term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi Constant term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi Debug term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi Define term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi Delimiter term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi Directive term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi Exception term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi Float term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi Format term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi Function term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi Identifier term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi Ignore term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi Include term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi Keyword term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi Label term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi Macro term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi Number term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi Operator term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi PreCondit term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi PreProc term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi Repeat term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi SpecialChar term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi SpecialComment term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi Special term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi Statement term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi StorageClass term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi String term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi Structure term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi Tag term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi Title term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi Typedef term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi Type term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi Underlined term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE

" Sneak
hi SneakLabelMask term=NONE cterm=NONE ctermfg=Black ctermbg=195 gui=NONE guifg=Black guibg=#d7ffff
hi SneakTarget term=NONE cterm=NONE ctermfg=Black ctermbg=195 gui=NONE guifg=Black guibg=#d7ffff
hi SneakLabelTarget term=NONE cterm=NONE ctermfg=Black ctermbg=183 gui=NONE guifg=Black guibg=#d7afff
hi SneakScope term=NONE cterm=NONE ctermfg=Black ctermbg=183 gui=NONE guifg=Black guibg=#d7afff

" Helper Functions
function! XMTDimCode()
    hi Comment term=NONE cterm=NONE ctermfg=White ctermbg=Black gui=NONE guifg=White guibg=Black
    hi Normal term=NONE cterm=NONE ctermfg=DarkCyan ctermbg=Black gui=NONE guifg=DarkCyan guibg=Black
    hi LineNr term=NONE cterm=NONE ctermfg=DarkCyan ctermbg=bg gui=NONE guifg=DarkCyan guibg=bg
    hi Character term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
    hi String term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
endfunction

function! XMTDimComments()
    hi Comment term=NONE cterm=NONE ctermfg=DarkCyan ctermbg=Black gui=NONE guifg=DarkCyan guibg=Black
    hi Normal term=NONE cterm=NONE ctermfg=White ctermbg=Black gui=NONE guifg=White guibg=Black
    hi LineNr term=NONE cterm=NONE ctermfg=DarkCyan ctermbg=bg gui=NONE guifg=DarkCyan guibg=bg
    hi Character term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
    hi String term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
endfunction

function! XMTNoDim()
    hi Comment term=NONE cterm=NONE ctermfg=DarkCyan ctermbg=Black gui=NONE guifg=DarkCyan guibg=Black
    hi Normal term=NONE cterm=NONE ctermfg=White ctermbg=Black gui=NONE guifg=White guibg=Black
    hi LineNr term=NONE cterm=NONE ctermfg=DarkCyan ctermbg=bg gui=NONE guifg=DarkCyan guibg=bg
    hi Character term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
    hi String term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
endfunction

" Command mappings
command! XMTColor :colo xmt
command! XMTNoDim :call XMTNoDim()
command! XMTDimComments :call XMTDimComments()
command! XMTDimCode :call XMTDimCode()

" Setup normal settings
call XMTNoDim()

