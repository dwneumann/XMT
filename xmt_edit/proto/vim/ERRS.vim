" syntax coloring for make/gcc output
syn match cMLogMissing	"[\./a-zA-Z0-9_]\+\.[a-zA-Z_]\+: No such .*$"
syn match cMLogMissing	"\<[Uu]ndefined reference to .*$"
syn match cMLogMissing	"No rule to make target .*$" 
syn match cMLogMissing	"No such .*$"
syn match cMLogDir	"Entering directory .*$" 
syn match cMLogWarn	"\<[wW]arning:.*$"
syn match cMLogErr	"\<[Ee]rror:.*$"
syn match cMLogErr	"\<multiple definition of .*$"
syn match cMLogErr	"\<section .* will not fit in region .*$"
syn match cMLogErr	"\<region .* overflowed .*$"

"syn match cMLogMissing  ".*$" contains=cMLogErr,cMLogSource


hi cMLogSource	guifg=DarkCyan
hi cMLogDir	guifg=DarkCyan
hi cMLogWarn	guifg=Yellow
hi cMLogErr	guifg=Red
hi cMLogMissing	guifg=Red

