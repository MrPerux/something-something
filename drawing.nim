## Local imports
import globals
import sdl_wrapper

## Library imports
import sdl2
import std/strformat

### Drawing
proc drawScreen*() =
    ## Background
    G.renderer.setDrawColor 8, 21, 27, 255 # dark cyan
    G.renderer.clear()

    ## Bottom bar
    G.renderer.setDrawColor(140, 140, 240, 255) # Light magenta
    var below_bar_rect = rect(
        0,
        G.height - 30,
        G.width,
        30)
    G.renderer.fillRect(below_bar_rect)
    drawText(16, cstring("FPS: " & fmt"{G.current_fps:>5.1f}"), color(255, 255, 255, 255), (30 - 16) div 2, G.height - 16 - (30 - 16) div 2)

    
    ## Show the result
    G.renderer.present()
