scheme: let
  c = scheme.colors // scheme.harmonized;
  hash = builtins.hashString "md5" (builtins.toJSON scheme.colors);
in
  /*
  vim
  */
  ''
    let g:colors_name="nix-${hash}"

    set termguicolors

    if exists("syntax_on")
      syntax reset
    endif

    hi clear

    hi Normal        guifg=${c.on_surface} guibg=${c.surface} gui=NONE guisp=NONE
    hi Bold          guifg=NONE guibg=NONE gui=bold guisp=NONE
    hi Debug         guifg=${c.red} guibg=NONE gui=NONE guisp=NONE
    hi Directory     guifg=${c.blue} guibg=NONE gui=NONE guisp=NONE
    hi Error         guifg=${c.surface} guibg=${c.red} gui=NONE guisp=NONE
    hi ErrorMsg      guifg=${c.red} guibg=${c.surface} gui=NONE guisp=NONE
    hi Exception     guifg=${c.red} guibg=NONE gui=NONE guisp=NONE
    hi FoldColumn    guifg=${c.cyan} guibg=${c.surface} gui=NONE guisp=NONE
    hi Folded        guifg=${c.on_primary_container} guibg=${c.primary_container} gui=NONE guisp=NONE
    hi IncSearch     guifg=${c.surface_variant} guibg=${c.primary} gui=NONE guisp=NONE
    hi Italic        guifg=NONE guibg=NONE gui=NONE guisp=NONE
    hi Macro         guifg=${c.red} guibg=NONE gui=NONE guisp=NONE
    hi MatchParen    guifg=NONE guibg=${c.primary_container} gui=NONE guisp=NONE
    hi ModeMsg       guifg=${c.green} guibg=NONE gui=NONE guisp=NONE
    hi MoreMsg       guifg=${c.green} guibg=NONE gui=NONE guisp=NONE
    hi Question      guifg=${c.blue} guibg=NONE gui=NONE guisp=NONE
    hi Search        guifg=${c.surface_variant} guibg=${c.yellow} gui=NONE guisp=NONE
    hi Substitute    guifg=${c.surface_variant} guibg=${c.yellow} gui=NONE guisp=NONE
    hi SpecialKey    guifg=${c.primary_container} guibg=NONE gui=NONE guisp=NONE
    hi TooLong       guifg=${c.red} guibg=NONE gui=NONE guisp=NONE
    hi Underlined    guifg=${c.red} guibg=NONE gui=NONE guisp=NONE
    hi Visual        guifg=NONE guibg=${c.tertiary_container} gui=NONE guisp=NONE
    hi VisualNOS     guifg=${c.red} guibg=NONE gui=NONE guisp=NONE
    hi WarningMsg    guifg=${c.red} guibg=NONE gui=NONE guisp=NONE
    hi WildMenu      guifg=${c.red} guibg=${c.yellow} gui=NONE guisp=NONE
    hi Title         guifg=${c.blue} guibg=NONE gui=NONE guisp=NONE
    hi Conceal       guifg=${c.blue} guibg=${c.surface} gui=NONE guisp=NONE
    hi Cursor        guifg=${c.surface} guibg=${c.on_surface} gui=NONE guisp=NONE
    hi NonText       guifg=${c.primary_container} guibg=NONE gui=NONE guisp=NONE
    hi LineNr        guifg=${c.on_surface_variant} guibg=${c.surface} gui=NONE guisp=NONE
    hi SignColumn    guifg=${c.on_surface_variant} guibg=${c.surface} gui=NONE guisp=NONE
    hi StatusLine    guifg=${c.on_surface_variant} guibg=${c.tertiary_container} gui=NONE guisp=NONE
    hi StatusLineNC  guifg=${c.surface_variant} guibg=${c.surface_variant} gui=NONE guisp=NONE
    hi VertSplit     guifg=${c.surface_variant} guibg=${c.surface} gui=NONE guisp=NONE
    hi ColorColumn   guifg=NONE guibg=${c.surface_variant} gui=NONE guisp=NONE
    hi CursorColumn  guifg=NONE guibg=${c.surface_variant} gui=NONE guisp=NONE
    hi CursorLine    guifg=NONE guibg=${c.tertiary_container} gui=NONE guisp=NONE
    hi CursorLineNr  guifg=${c.green} guibg=${c.surface_variant} gui=NONE guisp=NONE
    hi QuickFixLine  guifg=NONE guibg=${c.surface_variant} gui=NONE guisp=NONE
    hi PMenu         guifg=${c.on_surface} guibg=${c.surface_variant} gui=NONE guisp=NONE
    hi PMenuSel      guifg=${c.surface_variant} guibg=${c.on_surface} gui=NONE guisp=NONE
    hi TabLine       guifg=${c.primary_container} guibg=${c.surface_variant} gui=NONE guisp=NONE
    hi TabLineFill   guifg=${c.primary_container} guibg=${c.tertiary_container} gui=NONE guisp=NONE
    hi TabLineSel    guifg=${c.green} guibg=${c.surface_variant} gui=NONE guisp=NONE
    hi EndOfBuffer   guifg=${c.surface} guibg=NONE gui=NONE guisp=NONE

    hi Boolean       guifg=${c.primary} guibg=NONE gui=NONE guisp=NONE
    hi Character     guifg=${c.red} guibg=NONE gui=NONE guisp=NONE
    hi Comment       guifg=${c.primary_container} guibg=NONE gui=NONE guisp=NONE
    hi Conditional   guifg=${c.magenta} guibg=NONE gui=NONE guisp=NONE
    hi Constant      guifg=${c.primary} guibg=NONE gui=NONE guisp=NONE
    hi Define        guifg=${c.magenta} guibg=NONE gui=NONE guisp=NONE
    hi Delimiter     guifg=${c.error} guibg=NONE gui=NONE guisp=NONE
    hi Float         guifg=${c.primary} guibg=NONE gui=NONE guisp=NONE
    hi Function      guifg=${c.blue} guibg=NONE gui=NONE guisp=NONE
    hi Identifier    guifg=${c.red} guibg=NONE gui=NONE guisp=NONE
    hi Include       guifg=${c.blue} guibg=NONE gui=NONE guisp=NONE
    hi Keyword       guifg=${c.magenta} guibg=NONE gui=NONE guisp=NONE
    hi Label         guifg=${c.yellow} guibg=NONE gui=NONE guisp=NONE
    hi Number        guifg=${c.primary} guibg=NONE gui=NONE guisp=NONE
    hi Operator      guifg=${c.on_surface} guibg=NONE gui=NONE guisp=NONE
    hi PreProc       guifg=${c.yellow} guibg=NONE gui=NONE guisp=NONE
    hi Repeat        guifg=${c.yellow} guibg=NONE gui=NONE guisp=NONE
    hi Special       guifg=${c.cyan} guibg=NONE gui=NONE guisp=NONE
    hi SpecialChar   guifg=${c.error} guibg=NONE gui=NONE guisp=NONE
    hi Statement     guifg=${c.red} guibg=NONE gui=NONE guisp=NONE
    hi StorageClass  guifg=${c.yellow} guibg=NONE gui=NONE guisp=NONE
    hi String        guifg=${c.green} guibg=NONE gui=NONE guisp=NONE
    hi Structure     guifg=${c.magenta} guibg=NONE gui=NONE guisp=NONE
    hi Tag           guifg=${c.yellow} guibg=NONE gui=NONE guisp=NONE
    hi Type          guifg=${c.yellow} guibg=NONE gui=NONE guisp=NONE
    hi Typedef       guifg=${c.yellow} guibg=NONE gui=NONE guisp=NONE

    hi Todo          guifg=${c.surface_variant} guibg=${c.yellow} gui=NONE guisp=NONE
    hi Done          guifg=${c.surface_variant} guibg=${c.green} gui=NONE guisp=NONE
    hi Start         guifg=${c.surface_variant} guibg=${c.blue} gui=NONE guisp=NONE
    hi End           guifg=${c.surface_variant} guibg=${c.magenta} gui=NONE guisp=NONE

    hi DiffAdd      guifg=${c.green} guibg=${c.surface} gui=NONE guisp=NONE
    hi DiffChange   guifg=${c.primary_container} guibg=${c.surface} gui=NONE guisp=NONE
    hi DiffDelete   guifg=${c.red} guibg=${c.surface} gui=NONE guisp=NONE
    hi DiffText     guifg=${c.blue} guibg=${c.surface} gui=NONE guisp=NONE
    hi DiffAdded    guifg=${c.green} guibg=${c.surface} gui=NONE guisp=NONE
    hi DiffFile     guifg=${c.red} guibg=${c.surface} gui=NONE guisp=NONE
    hi DiffNewFile  guifg=${c.green} guibg=${c.surface} gui=NONE guisp=NONE
    hi DiffLine     guifg=${c.blue} guibg=${c.surface} gui=NONE guisp=NONE
    hi DiffRemoved  guifg=${c.red} guibg=${c.surface} gui=NONE guisp=NONE

    hi gitcommitOverflow       guifg=${c.red} guibg=NONE gui=NONE guisp=NONE
    hi gitcommitSummary        guifg=${c.green} guibg=NONE gui=NONE guisp=NONE
    hi gitcommitComment        guifg=${c.primary_container} guibg=NONE gui=NONE guisp=NONE
    hi gitcommitUntracked      guifg=${c.primary_container} guibg=NONE gui=NONE guisp=NONE
    hi gitcommitDiscarded      guifg=${c.primary_container} guibg=NONE gui=NONE guisp=NONE
    hi gitcommitSelected       guifg=${c.primary_container} guibg=NONE gui=NONE guisp=NONE
    hi gitcommitHeader         guifg=${c.magenta} guibg=NONE gui=NONE guisp=NONE
    hi gitcommitSelectedType   guifg=${c.blue} guibg=NONE gui=NONE guisp=NONE
    hi gitcommitUnmergedType   guifg=${c.blue} guibg=NONE gui=NONE guisp=NONE
    hi gitcommitDiscardedType  guifg=${c.blue} guibg=NONE gui=NONE guisp=NONE
    hi gitcommitBranch         guifg=${c.primary} guibg=NONE gui=bold guisp=NONE
    hi gitcommitUntrackedFile  guifg=${c.yellow} guibg=NONE gui=NONE guisp=NONE
    hi gitcommitUnmergedFile   guifg=${c.red} guibg=NONE gui=bold guisp=NONE
    hi gitcommitDiscardedFile  guifg=${c.red} guibg=NONE gui=bold guisp=NONE
    hi gitcommitSelectedFile   guifg=${c.green} guibg=NONE gui=bold guisp=NONE

    hi GitGutterAdd           guifg=${c.green} guibg=${c.surface} gui=NONE guisp=NONE
    hi GitGutterChange        guifg=${c.blue} guibg=${c.surface} gui=NONE guisp=NONE
    hi GitGutterDelete        guifg=${c.red} guibg=${c.surface} gui=NONE guisp=NONE
    hi GitGutterChangeDelete  guifg=${c.magenta} guibg=${c.surface} gui=NONE guisp=NONE

    hi SpellBad    guifg=NONE guibg=NONE gui=undercurl guisp=${c.red}
    hi SpellLocal  guifg=NONE guibg=NONE gui=undercurl guisp=${c.cyan}
    hi SpellCap    guifg=NONE guibg=NONE gui=undercurl guisp=${c.blue}
    hi SpellRare   guifg=NONE guibg=NONE gui=undercurl guisp=${c.magenta}

    hi DiagnosticError                     guifg=${c.red} guibg=${c.surface_variant} gui=NONE guisp=NONE
    hi DiagnosticWarn                      guifg=${c.magenta} guibg=${c.surface_variant} gui=NONE guisp=NONE
    hi DiagnosticInfo                      guifg=${c.on_surface} guibg=${c.surface_variant} gui=NONE guisp=NONE
    hi DiagnosticHint                      guifg=${c.cyan} guibg=${c.surface_variant} gui=NONE guisp=NONE
    hi DiagnosticUnderlineError            guifg=NONE guibg=NONE gui=undercurl guisp=${c.red}
    hi DiagnosticUnderlineWarning          guifg=NONE guibg=NONE gui=undercurl guisp=${c.magenta}
    hi DiagnosticUnderlineWarn             guifg=NONE guibg=NONE gui=undercurl guisp=${c.magenta}
    hi DiagnosticUnderlineInformation      guifg=NONE guibg=NONE gui=undercurl guisp=${c.error}
    hi DiagnosticUnderlineHint             guifg=NONE guibg=NONE gui=undercurl guisp=${c.cyan}

    hi LspReferenceText                    guifg=NONE guibg=NONE gui=underline guisp=${c.on_surface_variant}
    hi LspReferenceRead                    guifg=NONE guibg=NONE gui=underline guisp=${c.on_surface_variant}
    hi LspReferenceWrite                   guifg=NONE guibg=NONE gui=underline guisp=${c.on_surface_variant}

    hi link LspDiagnosticsDefaultError         DiagnosticError
    hi link LspDiagnosticsDefaultWarning       DiagnosticWarn
    hi link LspDiagnosticsDefaultInformation   DiagnosticInfo
    hi link LspDiagnosticsDefaultHint          DiagnosticHint
    hi link LspDiagnosticsUnderlineError       DiagnosticUnderlineError
    hi link LspDiagnosticsUnderlineWarning     DiagnosticUnderlineWarning
    hi link LspDiagnosticsUnderlineInformation DiagnosticUnderlineInformation
    hi link LspDiagnosticsUnderlineHint        DiagnosticUnderlineHint

    hi TSAnnotation          guifg=${c.error} guibg=NONE gui=NONE guisp=NONE
    hi TSAttribute           guifg=${c.yellow} guibg=NONE gui=NONE guisp=NONE
    hi TSBoolean             guifg=${c.primary} guibg=NONE gui=NONE guisp=NONE
    hi TSCharacter           guifg=${c.red} guibg=NONE gui=NONE guisp=NONE
    hi TSComment             guifg=${c.primary_container} guibg=NONE gui=NONE guisp=NONE "was italic
    hi TSConstructor         guifg=${c.blue} guibg=NONE gui=NONE guisp=NONE
    hi TSConditional         guifg=${c.magenta} guibg=NONE gui=NONE guisp=NONE
    hi TSConstant            guifg=${c.primary} guibg=NONE gui=NONE guisp=NONE
    hi TSConstBuiltin        guifg=${c.primary} guibg=NONE gui=NONE guisp=NONE "was italic
    hi TSConstMacro          guifg=${c.red} guibg=NONE gui=NONE guisp=NONE
    hi TSError               guifg=${c.red} guibg=NONE gui=NONE guisp=NONE
    hi TSException           guifg=${c.red} guibg=NONE gui=NONE guisp=NONE
    hi TSField               guifg=${c.on_surface} guibg=NONE gui=NONE guisp=NONE
    hi TSFloat               guifg=${c.primary} guibg=NONE gui=NONE guisp=NONE
    hi TSFunction            guifg=${c.blue} guibg=NONE gui=NONE guisp=NONE
    hi TSFuncBuiltin         guifg=${c.blue} guibg=NONE gui=NONE guisp=NONE "was italic
    hi TSFuncMacro           guifg=${c.red} guibg=NONE gui=NONE guisp=NONE
    hi TSInclude             guifg=${c.blue} guibg=NONE gui=NONE guisp=NONE
    hi TSKeyword             guifg=${c.magenta} guibg=NONE gui=NONE guisp=NONE
    hi TSKeywordFunction     guifg=${c.magenta} guibg=NONE gui=NONE guisp=NONE
    hi TSKeywordOperator     guifg=${c.magenta} guibg=NONE gui=NONE guisp=NONE
    hi TSLabel               guifg=${c.yellow} guibg=NONE gui=NONE guisp=NONE
    hi TSMethod              guifg=${c.blue} guibg=NONE gui=NONE guisp=NONE
    hi TSNamespace           guifg=${c.red} guibg=NONE gui=NONE guisp=NONE
    hi TSNone                guifg=${c.on_surface} guibg=NONE gui=NONE guisp=NONE
    hi TSNumber              guifg=${c.primary} guibg=NONE gui=NONE guisp=NONE
    hi TSOperator            guifg=${c.on_surface} guibg=NONE gui=NONE guisp=NONE
    hi TSParameter           guifg=${c.on_surface} guibg=NONE gui=NONE guisp=NONE
    hi TSParameterReference  guifg=${c.on_surface} guibg=NONE gui=NONE guisp=NONE
    hi TSProperty            guifg=${c.on_surface} guibg=NONE gui=NONE guisp=NONE
    hi TSPunctDelimiter      guifg=${c.error} guibg=NONE gui=NONE guisp=NONE
    hi TSPunctBracket        guifg=${c.on_surface} guibg=NONE gui=NONE guisp=NONE
    hi TSPunctSpecial        guifg=${c.on_surface} guibg=NONE gui=NONE guisp=NONE
    hi TSRepeat              guifg=${c.yellow} guibg=NONE gui=NONE guisp=NONE
    hi TSString              guifg=${c.green} guibg=NONE gui=NONE guisp=NONE
    hi TSStringRegex         guifg=${c.cyan} guibg=NONE gui=NONE guisp=NONE
    hi TSStringEscape        guifg=${c.cyan} guibg=NONE gui=NONE guisp=NONE
    hi TSSymbol              guifg=${c.green} guibg=NONE gui=NONE guisp=NONE
    hi TSTag                 guifg=${c.yellow} guibg=NONE gui=NONE guisp=NONE
    hi TSTagDelimiter        guifg=${c.error} guibg=NONE gui=NONE guisp=NONE
    hi TSText                guifg=${c.on_surface} guibg=NONE gui=NONE guisp=NONE
    hi TSStrong              guifg=NONE guibg=NONE gui=bold guisp=NONE
    hi TSEmphasis            guifg=${c.primary} guibg=NONE gui=NONE guisp=NONE "was italic
    hi TSUnderline           guifg=${c.surface} guibg=NONE gui=underline guisp=NONE
    hi TSStrike              guifg=${c.surface} guibg=NONE gui=strikethrough guisp=NONE
    hi TSTitle               guifg=${c.blue} guibg=NONE gui=NONE guisp=NONE
    hi TSLiteral             guifg=${c.primary} guibg=NONE gui=NONE guisp=NONE
    hi TSURI                 guifg=${c.primary} guibg=NONE gui=underline guisp=NONE
    hi TSType                guifg=${c.yellow} guibg=NONE gui=NONE guisp=NONE
    hi TSTypeBuiltin         guifg=${c.yellow} guibg=NONE gui=NONE guisp=NONE "was italic
    hi TSVariable            guifg=${c.red} guibg=NONE gui=NONE guisp=NONE
    hi TSVariableBuiltin     guifg=${c.red} guibg=NONE gui=NONE guisp=NONE "was italic

    hi TSDefinition          guifg=NONE guibg=NONE gui=underline guisp=${c.on_surface_variant}
    hi TSDefinitionUsage     guifg=NONE guibg=NONE gui=underline guisp=${c.on_surface_variant}
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

    hi IndentBlankLine       guifg=${c.surface_variant} guibg=NONE gui=NONE guisp=NONE

    hi NvimTreeNormal        guifg=${c.on_surface} guibg=${c.surface} gui=NONE guisp=NONE

    hi CmpItemAbbr            guifg=${c.on_surface} guibg=NONE gui=NONE guisp=NONE
    hi CmpItemAbbrDeprecated  guifg=${c.primary_container} guibg=NONE gui=NONE guisp=NONE
    hi CmpItemAbbrMatch       guifg=${c.on_surface} guibg=NONE gui=NONE guisp=NONE
    hi CmpItemAbbrMatchFuzzy  guifg=${c.on_surface} guibg=NONE gui=NONE guisp=NONE
    hi CmpItemKind            guifg=${c.cyan} guibg=NONE gui=NONE guisp=NONE
    hi CmpItemMenu            guifg=${c.on_surface} guibg=NONE gui=NONE guisp=NONE

    hi BufferCurrent         guifg=${c.green} guibg=${c.surface} gui=NONE guisp=NONE
    hi BufferCurrentIndex    guifg=${c.green} guibg=${c.surface} gui=NONE guisp=NONE
    hi BufferCurrentMod      guifg=${c.magenta} guibg=${c.surface} gui=NONE guisp=NONE
    hi BufferCurrentSign     guifg=${c.green} guibg=${c.surface} gui=NONE guisp=NONE
    hi BufferCurrentTarget   guifg=${c.red} guibg=${c.surface} gui=NONE guisp=NONE
    hi BufferCurrentIcon     guifg=NONE guibg=${c.surface} gui=NONE guisp=NONE
    hi BufferVisible         guifg=${c.yellow} guibg=${c.surface_variant} gui=NONE guisp=NONE
    hi BufferVisibleIndex    guifg=${c.yellow} guibg=${c.surface_variant} gui=NONE guisp=NONE
    hi BufferVisibleMod      guifg=${c.magenta} guibg=${c.surface_variant} gui=NONE guisp=NONE
    hi BufferVisibleSign     guifg=${c.yellow} guibg=${c.surface_variant} gui=NONE guisp=NONE
    hi BufferVisibleTarget   guifg=${c.red} guibg=${c.surface_variant} gui=NONE guisp=NONE
    hi BufferVisibleIcon     guifg=NONE guibg=${c.surface_variant} gui=NONE guisp=NONE
    hi BufferInactive        guifg=${c.on_surface_variant} guibg=${c.tertiary_container} gui=NONE guisp=NONE
    hi BufferInactiveIndex   guifg=${c.on_surface} guibg=${c.tertiary_container} gui=NONE guisp=NONE
    hi BufferInactiveMod     guifg=${c.magenta} guibg=${c.tertiary_container} gui=NONE guisp=NONE
    hi BufferInactiveSign    guifg=${c.on_surface} guibg=${c.tertiary_container} gui=NONE guisp=NONE
    hi BufferInactiveTarget  guifg=${c.red} guibg=${c.tertiary_container} gui=NONE guisp=NONE
    hi BufferInactiveIcon    guifg=NONE guibg=${c.tertiary_container} gui=NONE guisp=NONE
    hi BufferTabpages        guifg=${c.primary_container} guibg=${c.tertiary_container} gui=NONE guisp=NONE
    hi BufferTabpageFill     guifg=${c.primary_container} guibg=${c.tertiary_container} gui=NONE guisp=NONE

    hi NvimInternalError  guifg=${c.surface} guibg=${c.red} gui=NONE guisp=NONE

    hi NormalFloat   guifg=${c.on_surface} guibg=${c.surface} gui=NONE guisp=NONE
    hi FloatBorder   guifg=${c.on_surface} guibg=${c.surface} gui=NONE guisp=NONE
    hi NormalNC      guifg=${c.on_surface} guibg=${c.surface} gui=NONE guisp=NONE
    hi TermCursor    guifg=${c.surface} guibg=${c.on_surface} gui=NONE guisp=NONE
    hi TermCursorNC  guifg=${c.surface} guibg=${c.on_surface} gui=NONE guisp=NONE

    hi User1  guifg=${c.red} guibg=${c.tertiary_container} gui=NONE guisp=NONE
    hi User2  guifg=${c.magenta} guibg=${c.tertiary_container} gui=NONE guisp=NONE
    hi User3  guifg=${c.on_surface} guibg=${c.tertiary_container} gui=NONE guisp=NONE
    hi User4  guifg=${c.cyan} guibg=${c.tertiary_container} gui=NONE guisp=NONE
    hi User5  guifg=${c.surface_variant} guibg=${c.tertiary_container} gui=NONE guisp=NONE
    hi User6  guifg=${c.on_surface} guibg=${c.tertiary_container} gui=NONE guisp=NONE
    hi User7  guifg=${c.on_surface} guibg=${c.tertiary_container} gui=NONE guisp=NONE
    hi User8  guifg=${c.surface} guibg=${c.tertiary_container} gui=NONE guisp=NONE
    hi User9  guifg=${c.surface} guibg=${c.tertiary_container} gui=NONE guisp=NONE

    hi TreesitterContext  guifg=NONE guibg=${c.surface_variant} gui=NONE guisp=NONE "was italic

    let g:terminal_color_background = "${c.surface}"
    let g:terminal_color_foreground = "${c.on_surface}"

    let g:terminal_color_0  = "${c.surface}"
    let g:terminal_color_1  = "${c.red}"
    let g:terminal_color_2  = "${c.green}"
    let g:terminal_color_3  = "${c.yellow}"
    let g:terminal_color_4  = "${c.blue}"
    let g:terminal_color_5  = "${c.magenta}"
    let g:terminal_color_6  = "${c.cyan}"
    let g:terminal_color_7  = "${c.on_surface}"
    let g:terminal_color_8  = "${c.primary_container}"
    let g:terminal_color_9  = "${c.red}"
    let g:terminal_color_10 = "${c.green}"
    let g:terminal_color_11 = "${c.yellow}"
    let g:terminal_color_12 = "${c.blue}"
    let g:terminal_color_13 = "${c.magenta}"
    let g:terminal_color_14 = "${c.cyan}"
    let g:terminal_color_15 = "${c.on_primary_container}"
  ''
