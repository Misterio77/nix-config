if exists('b:current_syntax')
  finish
endif

let b:current_syntax = 'jj'

syn match jjAdded "A .*" contained
syn match jjRemoved "D .*" contained
syn match jjChanged "M .*" contained

syn region jjComment start="^JJ: " end="$" contains=jjAdded,jjRemoved,jjChanged

syn include @jjDiff syntax/diff.vim
syn region jjDiff start=/^JJ:      \%(diff --\%(git\|cc\|combined\) \)\@=/ end=/^$/ fold contains=@jjDiff
syn match jjDiffAdded "    \(+.*\)" contained containedin=jjDiff
syn match jjDiffRemoved "    \(-.*\)" contained containedin=jjDiff
syn match jjDiffHeader "    \(diff --\%(git\|cc\|combined\)\|index\|@@\) .*" contained containedin=jjDiff
syn match jjCommentPrefix "^\(JJ:\) \(.*\)\@=" contained containedin=jjDiff

hi def link jjCommentPrefix jjComment
hi def link jjComment Comment
hi def link jjAdded Added
hi def link jjRemoved Removed
hi def link jjChanged Changed
hi def link jjDiff Comment
hi def link jjDiffHeader Keyword
hi def link jjDiffAdded diffAdded
hi def link jjDiffRemoved diffRemoved
