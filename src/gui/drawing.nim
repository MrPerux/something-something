## Local imports
import ../globals
import lib_sdl
import ../types
import colors
import text_rendering
import lib_drawing

## Library imports
import sdl2

## Standard imports
{. warning[UnusedImport]:off .}
import sugar
import std/tables
import std/strutils
import std/options
import std/strformat
import system/dollars

### Drawing everything
proc drawScreen*() =
    ## Background
    G.renderer.setDrawColor(8, 21, 27, 255) ## Dark cyan
    G.renderer.clear()

    ## Bottom bar
    G.renderer.setDrawColor(140, 140, 240, 255) ## Light magenta
    var below_bar_rect = rect(
        0,
        G.height - 30,
        G.width,
        30)
    G.renderer.fillRect(below_bar_rect)
    # drawTextFast(G.standard_font, fmt"FPS: {G.current_fps:>5.1f}", whitestWhite, (30 - 16) div 2, G.height - 16 - (30 - 16) div 2)
    drawTextFastAlign(G.standard_font, fmt"FPS: {G.current_fps:>5.1f}", whitestWhite, (30 - G.standard_font.glyph_size) div 2, G.height - 30 div 2, Left, Center)
    drawTextFastAlign(G.standard_font, $G.focus_mode, whitestWhite, G.width - ((30 - G.standard_font.glyph_size) div 2), G.height - 30 div 2, Right, Center)
    
    ## Optional search bar
    if G.focus_mode == FocusMode.Search:
        G.renderer.setDrawColor(28, 41, 47, 255) ## Lighter cyan than background
        var search_bar_rect = rect(
            G.width div 2,
            0,
            G.width - (G.width div 2),
            30)
        G.renderer.fillRect(search_bar_rect)
        drawTextFast(G.standard_font, fmt"Search: '{G.current_search_term}'", whitestWhite, G.width div 2 + ((30 - 16) div 2), (30 - 16) div 2)

    ## Show the result
    G.renderer.present()
