## Local imports
import globals
import sdl_wrapper
import types

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
    drawStandardSizeTextFast(cstring(fmt"FPS: {G.current_fps:>5.1f}"), color(255, 255, 255, 255), 200, G.height - 16 - (30 - 16) div 2)
    
    ## Optional search bar
    if G.search_active:
        G.renderer.setDrawColor(28, 41, 47, 255) # Lighter cyan than background
        var search_bar = rect(
            G.width div 2,
            0,
            G.width - (G.width div 2),
            30)
        G.renderer.fillRect(search_bar)
        drawText(16, cstring(fmt"Search: '{G.current_search_term}'"), color(255, 255, 255, 255), G.width div 2 + ((30 - 16) div 2), (30 - 16) div 2)

    ## Texties
    var
        x_left: cint = 0
        x: cint = 0
        y: cint = 0
    for texty in G.texties:
        ## Spacing/layout
        if texty.kind == Spacing:
            for c in texty.text:
                case c
                of ' ':
                    x += 10
                of '\t':
                    x_left += 40
                    x = x_left
                of '\r':
                    x_left -= 40
                    x = x_left
                of '\n':
                    y += 16
                    x = x_left
                else:
                    raiseAssert(fmt"Invalid spacing character '{c}'")
            continue
        ## Colored Text
        let color =
            case texty.kind
            of Todo:
                color(130, 255, 160, 255)
            of Keyword:
                color(255, 130, 160, 255)
            else:
                color(255, 255, 255, 255)
        drawStandardSizeTextFast(cstring(texty.text), color, x, y)
        x += 10 * cast[cint](texty.text.len)

    ## Show the result
    G.renderer.present()
