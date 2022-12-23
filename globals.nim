## Local imports
import types

## Library imports
import os
import sdl2
import sdl2/ttf
import std/tables

type Globals* = object
    ## Window properties
    running*: bool
    width*: cint
    height*: cint
    window*: WindowPtr
    window_title*: cstring
    renderer*: RendererPtr
    current_fps*: float
    was_typing_apostrophe_like_character*: char
    
    ## Is screen maximized
    is_screen_maximized*: bool

    ## Current focus
    focus_stack*: seq[FocusMode]

    ## Search bar
    current_search_term*: string

    ## Creation window
    creation_window_search*: string
    creation_window_selection_index*: cint
    creation_window_selection_options*: seq[Texty]

    ## Goto window
    goto_window_search*: string
    goto_window_selection_index*: cint
    goto_window_selection_options*: seq[Texty]

    ## Texties
    show_texty_line_names*: bool
    texty_lines*: seq[NamedTextyLine]

    ## Fonts
    texture_atlas_standard_size*: TexturePtr
    fonts*: Table[cint, FontPtr]

var G* = Globals(running: true, is_screen_maximized: fileExists("runtime/maximized_mode.option"), focus_stack: @[FocusMode.Text], current_search_term: "poodles")

func focus_mode*(g: Globals): FocusMode =
    g.focus_stack[^1]
func current_text*(g: Globals): string =
    case g.focus_mode:
    of FocusMode.Search:
        g.current_search_term
    of FocusMode.Text:
        g.texty_lines[^1].texties[^1].text
    of FocusMode.CreationWindow:
        g.creation_window_search
    of FocusMode.GotoWindow:
        g.goto_window_search

G.texty_lines.add(initNamedTextyLine("yeah", @[Texty(text: "", kind: CurrentlyTyping, currently_typing_kind: Unparsed)]))
