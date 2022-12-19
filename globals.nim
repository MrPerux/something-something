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

    ## Search bar
    search_active*: bool
    current_search_term*: string

    ## Texties
    texties*: seq[Texty]

    ## Fonts
    texture_atlas_standard_size*: TexturePtr
    fonts*: Table[cint, FontPtr]

var G* = Globals(running: true, is_screen_maximized: fileExists("runtime/maximized_mode.option"), search_active: false, current_search_term: "bitches")

for i in 1..12:
    for word in @["width", "height", "window", "fps", "is_prime", "where_are_my_cats", "texties"]:
        for j in 1..5:
            G.texties.add(Texty(text: "proc", kind: Keyword))
            G.texties.add(Texty(text: " ", kind: Spacing))
            G.texties.add(Texty(text: word, kind: Todo))

            G.texties.add(Texty(text: "(", kind: Punctuation))
            G.texties.add(Texty(text: "int", kind: Keyword))
            G.texties.add(Texty(text: ",", kind: Punctuation))
            G.texties.add(Texty(text: " ", kind: Spacing))
            
            G.texties.add(Texty(text: "float", kind: Keyword))
            G.texties.add(Texty(text: ",", kind: Punctuation))
            G.texties.add(Texty(text: " ", kind: Spacing))
            
            G.texties.add(Texty(text: "double", kind: Keyword))
            G.texties.add(Texty(text: ")", kind: Punctuation))
            G.texties.add(Texty(text: " ", kind: Spacing))

            G.texties.add(Texty(text: "->", kind: Punctuation))
            G.texties.add(Texty(text: " ", kind: Spacing))

            G.texties.add(Texty(text: "type", kind: Todo))
            G.texties.add(Texty(text: " =", kind: Punctuation))
            G.texties.add(Texty(text: " ", kind: Spacing))

        G.texties.add(Texty(text: "\n", kind: Spacing))

G.texties.add(Texty(text: "", kind: Todo))
