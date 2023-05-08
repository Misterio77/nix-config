scheme:
let c = scheme.colors;
in /* vim */ ''
  let g:colors_name="nix-${scheme.slug}"

  set termguicolors

  if exists("syntax_on")
    syntax reset
  endif

  hi clear

  hi Normal        guifg=#${c.base05} guibg=#${c.base00} gui=NONE guisp=NONE
  hi Bold          guifg=NONE guibg=NONE gui=bold guisp=NONE
  hi Debug         guifg=#${c.base08} guibg=NONE gui=NONE guisp=NONE
  hi Directory     guifg=#${c.base0D} guibg=NONE gui=NONE guisp=NONE
  hi Error         guifg=#${c.base00} guibg=#${c.base08} gui=NONE guisp=NONE
  hi ErrorMsg      guifg=#${c.base08} guibg=#${c.base00} gui=NONE guisp=NONE
  hi Exception     guifg=#${c.base08} guibg=NONE gui=NONE guisp=NONE
  hi FoldColumn    guifg=#${c.base0C} guibg=#${c.base00} gui=NONE guisp=NONE
  hi Folded        guifg=#${c.base03} guibg=#${c.base01} gui=NONE guisp=NONE
  hi IncSearch     guifg=#${c.base01} guibg=#${c.base09} gui=NONE guisp=NONE
  hi Italic        guifg=NONE guibg=NONE gui=NONE guisp=NONE
  hi Macro         guifg=#${c.base08} guibg=NONE gui=NONE guisp=NONE
  hi MatchParen    guifg=NONE guibg=#${c.base03} gui=NONE guisp=NONE
  hi ModeMsg       guifg=#${c.base0B} guibg=NONE gui=NONE guisp=NONE
  hi MoreMsg       guifg=#${c.base0B} guibg=NONE gui=NONE guisp=NONE
  hi Question      guifg=#${c.base0D} guibg=NONE gui=NONE guisp=NONE
  hi Search        guifg=#${c.base01} guibg=#${c.base0A} gui=NONE guisp=NONE
  hi Substitute    guifg=#${c.base01} guibg=#${c.base0A} gui=NONE guisp=NONE
  hi SpecialKey    guifg=#${c.base03} guibg=NONE gui=NONE guisp=NONE
  hi TooLong       guifg=#${c.base08} guibg=NONE gui=NONE guisp=NONE
  hi Underlined    guifg=#${c.base08} guibg=NONE gui=NONE guisp=NONE
  hi Visual        guifg=NONE guibg=#${c.base02} gui=NONE guisp=NONE
  hi VisualNOS     guifg=#${c.base08} guibg=NONE gui=NONE guisp=NONE
  hi WarningMsg    guifg=#${c.base08} guibg=NONE gui=NONE guisp=NONE
  hi WildMenu      guifg=#${c.base08} guibg=#${c.base0A} gui=NONE guisp=NONE
  hi Title         guifg=#${c.base0D} guibg=NONE gui=NONE guisp=NONE
  hi Conceal       guifg=#${c.base0D} guibg=#${c.base00} gui=NONE guisp=NONE
  hi Cursor        guifg=#${c.base00} guibg=#${c.base05} gui=NONE guisp=NONE
  hi NonText       guifg=#${c.base03} guibg=NONE gui=NONE guisp=NONE
  hi LineNr        guifg=#${c.base04} guibg=#${c.base00} gui=NONE guisp=NONE
  hi SignColumn    guifg=#${c.base04} guibg=#${c.base00} gui=NONE guisp=NONE
  hi StatusLine    guifg=#${c.base0B} guibg=#${c.base02} gui=NONE guisp=NONE
  hi StatusLineNC  guifg=#${c.base04} guibg=#${c.base01} gui=NONE guisp=NONE
  hi VertSplit     guifg=#${c.base01} guibg=#${c.base00} gui=NONE guisp=NONE
  hi ColorColumn   guifg=NONE guibg=#${c.base01} gui=NONE guisp=NONE
  hi CursorColumn  guifg=NONE guibg=#${c.base01} gui=NONE guisp=NONE
  hi CursorLine    guifg=NONE guibg=#${c.base02} gui=NONE guisp=NONE
  hi CursorLineNr  guifg=#${c.base0B} guibg=#${c.base01} gui=NONE guisp=NONE
  hi QuickFixLine  guifg=NONE guibg=#${c.base01} gui=NONE guisp=NONE
  hi PMenu         guifg=#${c.base05} guibg=#${c.base01} gui=NONE guisp=NONE
  hi PMenuSel      guifg=#${c.base01} guibg=#${c.base05} gui=NONE guisp=NONE
  hi TabLine       guifg=#${c.base03} guibg=#${c.base01} gui=NONE guisp=NONE
  hi TabLineFill   guifg=#${c.base03} guibg=#${c.base02} gui=NONE guisp=NONE
  hi TabLineSel    guifg=#${c.base0B} guibg=#${c.base01} gui=NONE guisp=NONE
  hi EndOfBuffer   guifg=#${c.base00} guibg=NONE gui=NONE guisp=NONE

  hi Boolean       guifg=#${c.base09} guibg=NONE gui=NONE guisp=NONE
  hi Character     guifg=#${c.base08} guibg=NONE gui=NONE guisp=NONE
  hi Comment       guifg=#${c.base03} guibg=NONE gui=NONE guisp=NONE
  hi Conditional   guifg=#${c.base0E} guibg=NONE gui=NONE guisp=NONE
  hi Constant      guifg=#${c.base09} guibg=NONE gui=NONE guisp=NONE
  hi Define        guifg=#${c.base0E} guibg=NONE gui=NONE guisp=NONE
  hi Delimiter     guifg=#${c.base0F} guibg=NONE gui=NONE guisp=NONE
  hi Float         guifg=#${c.base09} guibg=NONE gui=NONE guisp=NONE
  hi Function      guifg=#${c.base0D} guibg=NONE gui=NONE guisp=NONE
  hi Identifier    guifg=#${c.base08} guibg=NONE gui=NONE guisp=NONE
  hi Include       guifg=#${c.base0D} guibg=NONE gui=NONE guisp=NONE
  hi Keyword       guifg=#${c.base0E} guibg=NONE gui=NONE guisp=NONE
  hi Label         guifg=#${c.base0A} guibg=NONE gui=NONE guisp=NONE
  hi Number        guifg=#${c.base09} guibg=NONE gui=NONE guisp=NONE
  hi Operator      guifg=#${c.base05} guibg=NONE gui=NONE guisp=NONE
  hi PreProc       guifg=#${c.base0A} guibg=NONE gui=NONE guisp=NONE
  hi Repeat        guifg=#${c.base0A} guibg=NONE gui=NONE guisp=NONE
  hi Special       guifg=#${c.base0C} guibg=NONE gui=NONE guisp=NONE
  hi SpecialChar   guifg=#${c.base0F} guibg=NONE gui=NONE guisp=NONE
  hi Statement     guifg=#${c.base08} guibg=NONE gui=NONE guisp=NONE
  hi StorageClass  guifg=#${c.base0A} guibg=NONE gui=NONE guisp=NONE
  hi String        guifg=#${c.base0B} guibg=NONE gui=NONE guisp=NONE
  hi Structure     guifg=#${c.base0E} guibg=NONE gui=NONE guisp=NONE
  hi Tag           guifg=#${c.base0A} guibg=NONE gui=NONE guisp=NONE
  hi Type          guifg=#${c.base0A} guibg=NONE gui=NONE guisp=NONE
  hi Typedef       guifg=#${c.base0A} guibg=NONE gui=NONE guisp=NONE

  hi Todo          guifg=#${c.base01} guibg=#${c.base0A} gui=NONE guisp=NONE
  hi Done          guifg=#${c.base01} guibg=#${c.base0B} gui=NONE guisp=NONE
  hi Start         guifg=#${c.base01} guibg=#${c.base0D} gui=NONE guisp=NONE
  hi End           guifg=#${c.base01} guibg=#${c.base0E} gui=NONE guisp=NONE

  hi DiffAdd      guifg=#${c.base0B} guibg=#${c.base00} gui=NONE guisp=NONE
  hi DiffChange   guifg=#${c.base03} guibg=#${c.base00} gui=NONE guisp=NONE
  hi DiffDelete   guifg=#${c.base08} guibg=#${c.base00} gui=NONE guisp=NONE
  hi DiffText     guifg=#${c.base0D} guibg=#${c.base00} gui=NONE guisp=NONE
  hi DiffAdded    guifg=#${c.base0B} guibg=#${c.base00} gui=NONE guisp=NONE
  hi DiffFile     guifg=#${c.base08} guibg=#${c.base00} gui=NONE guisp=NONE
  hi DiffNewFile  guifg=#${c.base0B} guibg=#${c.base00} gui=NONE guisp=NONE
  hi DiffLine     guifg=#${c.base0D} guibg=#${c.base00} gui=NONE guisp=NONE
  hi DiffRemoved  guifg=#${c.base08} guibg=#${c.base00} gui=NONE guisp=NONE

  hi gitcommitOverflow       guifg=#${c.base08} guibg=NONE gui=NONE guisp=NONE
  hi gitcommitSummary        guifg=#${c.base0B} guibg=NONE gui=NONE guisp=NONE
  hi gitcommitComment        guifg=#${c.base03} guibg=NONE gui=NONE guisp=NONE
  hi gitcommitUntracked      guifg=#${c.base03} guibg=NONE gui=NONE guisp=NONE
  hi gitcommitDiscarded      guifg=#${c.base03} guibg=NONE gui=NONE guisp=NONE
  hi gitcommitSelected       guifg=#${c.base03} guibg=NONE gui=NONE guisp=NONE
  hi gitcommitHeader         guifg=#${c.base0E} guibg=NONE gui=NONE guisp=NONE
  hi gitcommitSelectedType   guifg=#${c.base0D} guibg=NONE gui=NONE guisp=NONE
  hi gitcommitUnmergedType   guifg=#${c.base0D} guibg=NONE gui=NONE guisp=NONE
  hi gitcommitDiscardedType  guifg=#${c.base0D} guibg=NONE gui=NONE guisp=NONE
  hi gitcommitBranch         guifg=#${c.base09} guibg=NONE gui=bold guisp=NONE
  hi gitcommitUntrackedFile  guifg=#${c.base0A} guibg=NONE gui=NONE guisp=NONE
  hi gitcommitUnmergedFile   guifg=#${c.base08} guibg=NONE gui=bold guisp=NONE
  hi gitcommitDiscardedFile  guifg=#${c.base08} guibg=NONE gui=bold guisp=NONE
  hi gitcommitSelectedFile   guifg=#${c.base0B} guibg=NONE gui=bold guisp=NONE

  hi GitGutterAdd           guifg=#${c.base0B} guibg=#${c.base00} gui=NONE guisp=NONE
  hi GitGutterChange        guifg=#${c.base0D} guibg=#${c.base00} gui=NONE guisp=NONE
  hi GitGutterDelete        guifg=#${c.base08} guibg=#${c.base00} gui=NONE guisp=NONE
  hi GitGutterChangeDelete  guifg=#${c.base0E} guibg=#${c.base00} gui=NONE guisp=NONE

  hi SpellBad    guifg=NONE guibg=NONE gui=undercurl guisp=#${c.base08}
  hi SpellLocal  guifg=NONE guibg=NONE gui=undercurl guisp=#${c.base0C}
  hi SpellCap    guifg=NONE guibg=NONE gui=undercurl guisp=#${c.base0D}
  hi SpellRare   guifg=NONE guibg=NONE gui=undercurl guisp=#${c.base0E}

  hi DiagnosticError                     guifg=#${c.base08} guibg=#${c.base01} gui=NONE guisp=NONE
  hi DiagnosticWarn                      guifg=#${c.base0E} guibg=#${c.base01} gui=NONE guisp=NONE
  hi DiagnosticInfo                      guifg=#${c.base05} guibg=#${c.base01} gui=NONE guisp=NONE
  hi DiagnosticHint                      guifg=#${c.base0C} guibg=#${c.base01} gui=NONE guisp=NONE
  hi DiagnosticUnderlineError            guifg=NONE guibg=NONE gui=undercurl guisp=#${c.base08}
  hi DiagnosticUnderlineWarning          guifg=NONE guibg=NONE gui=undercurl guisp=#${c.base0E}
  hi DiagnosticUnderlineWarn             guifg=NONE guibg=NONE gui=undercurl guisp=#${c.base0E}
  hi DiagnosticUnderlineInformation      guifg=NONE guibg=NONE gui=undercurl guisp=#${c.base0F}
  hi DiagnosticUnderlineHint             guifg=NONE guibg=NONE gui=undercurl guisp=#${c.base0C}

  hi LspReferenceText                    guifg=NONE guibg=NONE gui=underline guisp=#${c.base04}
  hi LspReferenceRead                    guifg=NONE guibg=NONE gui=underline guisp=#${c.base04}
  hi LspReferenceWrite                   guifg=NONE guibg=NONE gui=underline guisp=#${c.base04}

  hi link LspDiagnosticsDefaultError         DiagnosticError
  hi link LspDiagnosticsDefaultWarning       DiagnosticWarn
  hi link LspDiagnosticsDefaultInformation   DiagnosticInfo
  hi link LspDiagnosticsDefaultHint          DiagnosticHint
  hi link LspDiagnosticsUnderlineError       DiagnosticUnderlineError
  hi link LspDiagnosticsUnderlineWarning     DiagnosticUnderlineWarning
  hi link LspDiagnosticsUnderlineInformation DiagnosticUnderlineInformation
  hi link LspDiagnosticsUnderlineHint        DiagnosticUnderlineHint

  hi TSAnnotation          guifg=#${c.base0F} guibg=NONE gui=NONE guisp=NONE
  hi TSAttribute           guifg=#${c.base0A} guibg=NONE gui=NONE guisp=NONE
  hi TSBoolean             guifg=#${c.base09} guibg=NONE gui=NONE guisp=NONE
  hi TSCharacter           guifg=#${c.base08} guibg=NONE gui=NONE guisp=NONE
  hi TSComment             guifg=#${c.base03} guibg=NONE gui=NONE guisp=NONE "was italic
  hi TSConstructor         guifg=#${c.base0D} guibg=NONE gui=NONE guisp=NONE
  hi TSConditional         guifg=#${c.base0E} guibg=NONE gui=NONE guisp=NONE
  hi TSConstant            guifg=#${c.base09} guibg=NONE gui=NONE guisp=NONE
  hi TSConstBuiltin        guifg=#${c.base09} guibg=NONE gui=NONE guisp=NONE "was italic
  hi TSConstMacro          guifg=#${c.base08} guibg=NONE gui=NONE guisp=NONE
  hi TSError               guifg=#${c.base08} guibg=NONE gui=NONE guisp=NONE
  hi TSException           guifg=#${c.base08} guibg=NONE gui=NONE guisp=NONE
  hi TSField               guifg=#${c.base05} guibg=NONE gui=NONE guisp=NONE
  hi TSFloat               guifg=#${c.base09} guibg=NONE gui=NONE guisp=NONE
  hi TSFunction            guifg=#${c.base0D} guibg=NONE gui=NONE guisp=NONE
  hi TSFuncBuiltin         guifg=#${c.base0D} guibg=NONE gui=NONE guisp=NONE "was italic
  hi TSFuncMacro           guifg=#${c.base08} guibg=NONE gui=NONE guisp=NONE
  hi TSInclude             guifg=#${c.base0D} guibg=NONE gui=NONE guisp=NONE
  hi TSKeyword             guifg=#${c.base0E} guibg=NONE gui=NONE guisp=NONE
  hi TSKeywordFunction     guifg=#${c.base0E} guibg=NONE gui=NONE guisp=NONE
  hi TSKeywordOperator     guifg=#${c.base0E} guibg=NONE gui=NONE guisp=NONE
  hi TSLabel               guifg=#${c.base0A} guibg=NONE gui=NONE guisp=NONE
  hi TSMethod              guifg=#${c.base0D} guibg=NONE gui=NONE guisp=NONE
  hi TSNamespace           guifg=#${c.base08} guibg=NONE gui=NONE guisp=NONE
  hi TSNone                guifg=#${c.base05} guibg=NONE gui=NONE guisp=NONE
  hi TSNumber              guifg=#${c.base09} guibg=NONE gui=NONE guisp=NONE
  hi TSOperator            guifg=#${c.base05} guibg=NONE gui=NONE guisp=NONE
  hi TSParameter           guifg=#${c.base05} guibg=NONE gui=NONE guisp=NONE
  hi TSParameterReference  guifg=#${c.base05} guibg=NONE gui=NONE guisp=NONE
  hi TSProperty            guifg=#${c.base05} guibg=NONE gui=NONE guisp=NONE
  hi TSPunctDelimiter      guifg=#${c.base0F} guibg=NONE gui=NONE guisp=NONE
  hi TSPunctBracket        guifg=#${c.base05} guibg=NONE gui=NONE guisp=NONE
  hi TSPunctSpecial        guifg=#${c.base05} guibg=NONE gui=NONE guisp=NONE
  hi TSRepeat              guifg=#${c.base0A} guibg=NONE gui=NONE guisp=NONE
  hi TSString              guifg=#${c.base0B} guibg=NONE gui=NONE guisp=NONE
  hi TSStringRegex         guifg=#${c.base0C} guibg=NONE gui=NONE guisp=NONE
  hi TSStringEscape        guifg=#${c.base0C} guibg=NONE gui=NONE guisp=NONE
  hi TSSymbol              guifg=#${c.base0B} guibg=NONE gui=NONE guisp=NONE
  hi TSTag                 guifg=#${c.base0A} guibg=NONE gui=NONE guisp=NONE
  hi TSTagDelimiter        guifg=#${c.base0F} guibg=NONE gui=NONE guisp=NONE
  hi TSText                guifg=#${c.base05} guibg=NONE gui=NONE guisp=NONE
  hi TSStrong              guifg=NONE guibg=NONE gui=bold guisp=NONE
  hi TSEmphasis            guifg=#${c.base09} guibg=NONE gui=NONE guisp=NONE "was italic
  hi TSUnderline           guifg=#${c.base00} guibg=NONE gui=underline guisp=NONE
  hi TSStrike              guifg=#${c.base00} guibg=NONE gui=strikethrough guisp=NONE
  hi TSTitle               guifg=#${c.base0D} guibg=NONE gui=NONE guisp=NONE
  hi TSLiteral             guifg=#${c.base09} guibg=NONE gui=NONE guisp=NONE
  hi TSURI                 guifg=#${c.base09} guibg=NONE gui=underline guisp=NONE
  hi TSType                guifg=#${c.base0A} guibg=NONE gui=NONE guisp=NONE
  hi TSTypeBuiltin         guifg=#${c.base0A} guibg=NONE gui=NONE guisp=NONE "was italic
  hi TSVariable            guifg=#${c.base08} guibg=NONE gui=NONE guisp=NONE
  hi TSVariableBuiltin     guifg=#${c.base08} guibg=NONE gui=NONE guisp=NONE "was italic

  hi TSDefinition          guifg=NONE guibg=NONE gui=underline guisp=#${c.base04}
  hi TSDefinitionUsage     guifg=NONE guibg=NONE gui=underline guisp=#${c.base04}
  hi TSCurrentScope        guifg=NONE guibg=NONE gui=bold guisp=NONE
  if has('nvim-0.8.0')
    highlight! link @annotation TSAnnotation
    highlight! link @attribute TSAttribute
    highlight! link @boolean TSBoolean
    highlight! link @character TSCharacter
    highlight! link @comment TSComment
    highlight! link @conditional TSConditional
    highlight! link @constant TSConstant
    highlight! link @constant.builtin TSConstBuiltin
    highlight! link @constant.macro TSConstMacro
    highlight! link @constructor TSConstructor
    highlight! link @exception TSException
    highlight! link @field TSField
    highlight! link @float TSFloat
    highlight! link @function TSFunction
    highlight! link @function.builtin TSFuncBuiltin
    highlight! link @function.macro TSFuncMacro
    highlight! link @include TSInclude
    highlight! link @keyword TSKeyword
    highlight! link @keyword.function TSKeywordFunction
    highlight! link @keyword.operator TSKeywordOperator
    highlight! link @label TSLabel
    highlight! link @method TSMethod
    highlight! link @namespace TSNamespace
    highlight! link @none TSNone
    highlight! link @number TSNumber
    highlight! link @operator TSOperator
    highlight! link @parameter TSParameter
    highlight! link @parameter.reference TSParameterReference
    highlight! link @property TSProperty
    highlight! link @punctuation.bracket TSPunctBracket
    highlight! link @punctuation.delimiter TSPunctDelimiter
    highlight! link @punctuation.special TSPunctSpecial
    highlight! link @repeat TSRepeat
    highlight! link @storageclass TSStorageClass
    highlight! link @string TSString
    highlight! link @string.escape TSStringEscape
    highlight! link @string.regex TSStringRegex
    highlight! link @symbol TSSymbol
    highlight! link @tag TSTag
    highlight! link @tag.delimiter TSTagDelimiter
    highlight! link @text TSText
    highlight! link @strike TSStrike
    highlight! link @math TSMath
    highlight! link @type TSType
    highlight! link @type.builtin TSTypeBuiltin
    highlight! link @uri TSURI
    highlight! link @variable TSVariable
    highlight! link @variable.builtin TSVariableBuiltin
  endif

  hi IndentBlankLine       guifg=#${c.base01} guibg=NONE gui=NONE guisp=NONE

  hi NvimTreeNormal        guifg=#${c.base05} guibg=#${c.base00} gui=NONE guisp=NONE

  hi CmpItemAbbr            guifg=#${c.base05} guibg=NONE gui=NONE guisp=NONE
  hi CmpItemAbbrDeprecated  guifg=#${c.base03} guibg=NONE gui=NONE guisp=NONE
  hi CmpItemAbbrMatch       guifg=#${c.base05} guibg=NONE gui=NONE guisp=NONE
  hi CmpItemAbbrMatchFuzzy  guifg=#${c.base05} guibg=NONE gui=NONE guisp=NONE
  hi CmpItemKind            guifg=#${c.base0C} guibg=NONE gui=NONE guisp=NONE
  hi CmpItemMenu            guifg=#${c.base05} guibg=NONE gui=NONE guisp=NONE

  hi BufferCurrent         guifg=#${c.base0B} guibg=#${c.base00} gui=NONE guisp=NONE
  hi BufferCurrentIndex    guifg=#${c.base0B} guibg=#${c.base00} gui=NONE guisp=NONE
  hi BufferCurrentMod      guifg=#${c.base0E} guibg=#${c.base00} gui=NONE guisp=NONE
  hi BufferCurrentSign     guifg=#${c.base0B} guibg=#${c.base00} gui=NONE guisp=NONE
  hi BufferCurrentTarget   guifg=#${c.base08} guibg=#${c.base00} gui=NONE guisp=NONE
  hi BufferCurrentIcon     guifg=NONE guibg=#${c.base00} gui=NONE guisp=NONE
  hi BufferVisible         guifg=#${c.base0A} guibg=#${c.base01} gui=NONE guisp=NONE
  hi BufferVisibleIndex    guifg=#${c.base0A} guibg=#${c.base01} gui=NONE guisp=NONE
  hi BufferVisibleMod      guifg=#${c.base0E} guibg=#${c.base01} gui=NONE guisp=NONE
  hi BufferVisibleSign     guifg=#${c.base0A} guibg=#${c.base01} gui=NONE guisp=NONE
  hi BufferVisibleTarget   guifg=#${c.base08} guibg=#${c.base01} gui=NONE guisp=NONE
  hi BufferVisibleIcon     guifg=NONE guibg=#${c.base01} gui=NONE guisp=NONE
  hi BufferInactive        guifg=#${c.base04} guibg=#${c.base02} gui=NONE guisp=NONE
  hi BufferInactiveIndex   guifg=#${c.base05} guibg=#${c.base02} gui=NONE guisp=NONE
  hi BufferInactiveMod     guifg=#${c.base0E} guibg=#${c.base02} gui=NONE guisp=NONE
  hi BufferInactiveSign    guifg=#${c.base05} guibg=#${c.base02} gui=NONE guisp=NONE
  hi BufferInactiveTarget  guifg=#${c.base08} guibg=#${c.base02} gui=NONE guisp=NONE
  hi BufferInactiveIcon    guifg=NONE guibg=#${c.base02} gui=NONE guisp=NONE
  hi BufferTabpages        guifg=#${c.base03} guibg=#${c.base02} gui=NONE guisp=NONE
  hi BufferTabpageFill     guifg=#${c.base03} guibg=#${c.base02} gui=NONE guisp=NONE

  hi NvimInternalError  guifg=#${c.base00} guibg=#${c.base08} gui=NONE guisp=NONE

  hi NormalFloat   guifg=#${c.base05} guibg=#${c.base00} gui=NONE guisp=NONE
  hi FloatBorder   guifg=#${c.base05} guibg=#${c.base00} gui=NONE guisp=NONE
  hi NormalNC      guifg=#${c.base05} guibg=#${c.base00} gui=NONE guisp=NONE
  hi TermCursor    guifg=#${c.base00} guibg=#${c.base05} gui=NONE guisp=NONE
  hi TermCursorNC  guifg=#${c.base00} guibg=#${c.base05} gui=NONE guisp=NONE

  hi User1  guifg=#${c.base08} guibg=#${c.base02} gui=NONE guisp=NONE
  hi User2  guifg=#${c.base0E} guibg=#${c.base02} gui=NONE guisp=NONE
  hi User3  guifg=#${c.base05} guibg=#${c.base02} gui=NONE guisp=NONE
  hi User4  guifg=#${c.base0C} guibg=#${c.base02} gui=NONE guisp=NONE
  hi User5  guifg=#${c.base01} guibg=#${c.base02} gui=NONE guisp=NONE
  hi User6  guifg=#${c.base05} guibg=#${c.base02} gui=NONE guisp=NONE
  hi User7  guifg=#${c.base05} guibg=#${c.base02} gui=NONE guisp=NONE
  hi User8  guifg=#${c.base00} guibg=#${c.base02} gui=NONE guisp=NONE
  hi User9  guifg=#${c.base00} guibg=#${c.base02} gui=NONE guisp=NONE

  hi TreesitterContext  guifg=NONE guibg=#${c.base01} gui=NONE guisp=NONE "was italic

  let g:terminal_color_background = "#${c.base00}"
  let g:terminal_color_foreground = "#${c.base05}"

  let g:terminal_color_0  = "#${c.base00}"
  let g:terminal_color_1  = "#${c.base08}"
  let g:terminal_color_2  = "#${c.base0B}"
  let g:terminal_color_3  = "#${c.base0A}"
  let g:terminal_color_4  = "#${c.base0D}"
  let g:terminal_color_5  = "#${c.base0E}"
  let g:terminal_color_6  = "#${c.base0C}"
  let g:terminal_color_7  = "#${c.base05}"
  let g:terminal_color_8  = "#${c.base03}"
  let g:terminal_color_9  = "#${c.base08}"
  let g:terminal_color_10 = "#${c.base0B}"
  let g:terminal_color_11 = "#${c.base0A}"
  let g:terminal_color_12 = "#${c.base0D}"
  let g:terminal_color_13 = "#${c.base0E}"
  let g:terminal_color_14 = "#${c.base0C}"
  let g:terminal_color_15 = "#${c.base07}"
''
