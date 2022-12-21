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
    
    ## Is screen maximized
    is_screen_maximized*: bool

    ## Current focus
    focus_stack*: seq[FocusMode]

    ## Search bar
    current_search_term*: string

    ## Creation window
    creation_window_search*: string

    ## Texties
    texties*: seq[Texty]

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
        g.texties[^1].text
    of FocusMode.CreationWindow:
        g.creation_window_search
    # else:
    #     ""

# for i in 1..12:
#     for word in @["width", "height", "window", "fps", "is_prime", "where_are_my_cats", "texties"]:
#         for j in 1..5:
#             G.texties.add(Texty(text: "proc", kind: Keyword))
#             G.texties.add(Texty(text: " ", kind: Spacing))
#             G.texties.add(Texty(text: word, kind: Todo))

#             G.texties.add(Texty(text: "(", kind: Punctuation))
#             G.texties.add(Texty(text: "int", kind: Keyword))
#             G.texties.add(Texty(text: ",", kind: Punctuation))
#             G.texties.add(Texty(text: " ", kind: Spacing))
            
#             G.texties.add(Texty(text: "float", kind: Keyword))
#             G.texties.add(Texty(text: ",", kind: Punctuation))
#             G.texties.add(Texty(text: " ", kind: Spacing))
            
#             G.texties.add(Texty(text: "double", kind: Keyword))
#             G.texties.add(Texty(text: ")", kind: Punctuation))
#             G.texties.add(Texty(text: " ", kind: Spacing))

#             G.texties.add(Texty(text: "->", kind: Punctuation))
#             G.texties.add(Texty(text: " ", kind: Spacing))

#             G.texties.add(Texty(text: "type", kind: Todo))
#             G.texties.add(Texty(text: " =", kind: Punctuation))
#             G.texties.add(Texty(text: " ", kind: Spacing))

#         G.texties.add(Texty(text: "\n", kind: Spacing))

G.texties.add(Texty(text: "", kind: Todo))
