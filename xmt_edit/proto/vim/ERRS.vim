" syntax coloring for make/gcc output
syn match cMLogMissing  "[\./a-zA-Z0-9_]\+\.[a-zA-Z_]\+: No such .*$"
syn match cMLogMissing  "\<[Uu]ndefined reference to .*$"
syn match cMLogSource   "[\./a-zA-Z0-9_]\+\.[hci][pxn]\?[lp]\?\(:[0-9]\+\)\+:"
syn match cMLogCurDir   "Entering directory .*$" 

syn match cMLogWarn "\<[wW]arning:.*$"
syn match cMLogErr  "\<[Ee]rror:.*$"
syn match cMLogErr  "No such .*$"

"syn match cMLogMissing  ".*$" contains=cMLogErr,cMLogSource


hi cMLogWarn    guifg=Yellow
hi cMLogErr     guifg=Red
hi cMLogSource  guifg=DarkCyan
hi cMLogCurDir  guifg=DarkCyan
hi cMLogMissing guifg=Red

