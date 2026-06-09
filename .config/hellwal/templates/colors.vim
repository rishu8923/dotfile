hi clear
if exists("syntax_on")
  syntax reset
endif

let g:colors_name = "hellwal"

" Palette
let s:bg = '#%% background.hex %%'
let s:fg = '#%% foreground.hex %%'

let s:c0  = '#%% color0.hex %%'
let s:c1  = '#%% color1.hex %%'
let s:c2  = '#%% color2.hex %%'
let s:c3  = '#%% color3.hex %%'
let s:c4  = '#%% color4.hex %%'
let s:c5  = '#%% color5.hex %%'
let s:c6  = '#%% color6.hex %%'
let s:c7  = '#%% color7.hex %%'
let s:c8  = '#%% color8.hex %%'
let s:c9  = '#%% color9.hex %%'
let s:c10 = '#%% color10.hex %%'
let s:c11 = '#%% color11.hex %%'
let s:c12 = '#%% color12.hex %%'
let s:c13 = '#%% color13.hex %%'
let s:c14 = '#%% color14.hex %%'
let s:c15 = '#%% color15.hex %%'

" ==============================
" Core UI
" ==============================
hi Normal       guifg=s:fg guibg=s:bg
hi CursorLine   guibg=s:c0
hi LineNr       guifg=s:c8 guibg=NONE
hi CursorLineNr guifg=s:c4 guibg=NONE
hi VertSplit    guifg=s:c0 guibg=s:bg
hi StatusLine   guifg=s:fg guibg=s:c0
hi Pmenu        guifg=s:fg guibg=s:c0
hi PmenuSel     guifg=s:bg guibg=s:c4

" ==============================
" Syntax
" ==============================
hi Comment     guifg=s:c8 gui=italic
hi Constant    guifg=s:c3
hi String      guifg=s:c2
hi Identifier  guifg=s:c4
hi Function    guifg=s:c5
hi Statement   guifg=s:c1
hi Keyword     guifg=s:c1
hi Type        guifg=s:c6
hi Operator    guifg=s:c5

