## Local imports

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

    fonts*: Table[cint, FontPtr]

var G* = Globals(running: true)
