## Local imports
import types

## Library imports
import sdl2
import sdl2/ttf
import std/tables

type Globals* = object
    running*: bool
    width*: cint
    height*: cint
    window*: WindowPtr
    window_title*: cstring
    renderer*: RendererPtr
    current_fps*: float
    
    search_active*: bool
    current_search_term*: string

    texties*: seq[Texty]

    fonts*: Table[cint, FontPtr]

var G* = Globals(running: true, search_active: false, current_search_term: "bitches")
