## Local imports
import globals

## Library imports
import sdl2

proc drawScreen*() =
    G.renderer.setDrawColor 8, 21, 27, 255 # dark cyaan
    G.renderer.clear()
    G.renderer.present()
