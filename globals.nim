## Local imports

## Library imports
import sdl2

type Globals* = object
    running*: bool
    width*: cint
    height*: cint
    window*: WindowPtr
    window_title*: cstring
    renderer*: RendererPtr
    current_fps*: float

var G* = Globals(running: true)
