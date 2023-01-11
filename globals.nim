## Local imports
import types

## Library imports
import os
import sdl2
import sdl2/ttf
import std/tables
import std/options

{.experimental: "codeReordering".}

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
    debug_mode*: bool
    
    ## Is screen maximized
    is_screen_maximized*: bool

    ## Current focus
    focus_stack*: seq[FocusMode]

    ## Search bar
    current_search_term*: string

    ## Creation window
    creation_window_search*: string
    creation_window_selection_index*: cint
    creation_window_selection_options*: seq[KeywordOption]

    ## Goto window
    goto_window_search*: string
    goto_window_selection_index*: cint
    goto_window_selection_options*: seq[Texty]
    
    ## Editables
    optionally_selected_editable*: Option[Editable]
    optional_writing_context*: Option[WritingContext]
    all_editables*: seq[Editable]
    current_slice*: EditableBody
    current_slice_filter*: Filter

    ## Fonts
    switchable_fonts*: seq[FontInfo]
    standard_font*: FontInfo
    fonts*: Table[cint, FontPtr]


var G* = Globals(
    running: true,
    is_screen_maximized: fileExists("runtime/maximized_mode.option"),
    focus_stack: @[FocusMode.Text],
    current_search_term: "poodles",
    current_slice: EditableBody(),
)


func focus_mode*(g: Globals): FocusMode =
    g.focus_stack[^1]
func current_text*(g: Globals): string =
    case g.focus_mode:
    of FocusMode.Search:
        g.current_search_term
    of FocusMode.Text:
        if g.optionally_selected_editable.isSome and g.optionally_selected_editable.get() of EditableUnparsed:
            var editable_unparsed = cast[EditableUnparsed](g.optionally_selected_editable.get())
            editable_unparsed.value
        else:
            "" ## TODO: Shouldn't be getting shit atm
    of FocusMode.CreationWindow:
        g.creation_window_search
    of FocusMode.GotoWindow:
        g.goto_window_search
