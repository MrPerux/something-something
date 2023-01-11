## Local imports
import ../globals
import ../types
import lib_sdl
import colors

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

### Drawing functions
proc drawCursor*(font: FontInfo, x: cint, y: cint) =
    G.renderer.setDrawColor(cursorGrey)
    var cursor_rect = rect(x - 1, y - 2, 2, font.glyph_size + 2)
    sdlAssertSuccess G.renderer.drawRect(addr cursor_rect)

proc drawFilledRect*(color: Color, rect: Rect) =
    G.renderer.setDrawColor(color)
    var cursor_rect = rect
    sdlAssertSuccess G.renderer.fillRect(addr cursor_rect)

proc drawOutlinedRect*(color: Color, rect: Rect) =
    G.renderer.setDrawColor(color)
    var cursor_rect = rect
    sdlAssertSuccess G.renderer.drawRect(addr cursor_rect)

proc fillPaddedRoundedRect*(dstrect: Rect) =
    ## Rectangles
    const padding = 2
    var horizontal = rect(dstrect[0] - padding, dstrect[1], dstrect[2] + 2 * padding, dstrect[3])
    G.renderer.fillRect(addr horizontal)
    var top = rect(dstrect[0], dstrect[1] - padding, dstrect[2], padding)
    G.renderer.fillRect(addr top)
    var bottom = rect(dstrect[0], dstrect[1] + dstrect[3], dstrect[2], padding)
    G.renderer.fillRect(addr bottom)
    
    ## Corners
    G.renderer.drawPoint(         dstrect[0] - 1,          dstrect[1] - 1)
    G.renderer.drawPoint(dstrect[0] + dstrect[2],          dstrect[1] - 1)
    G.renderer.drawPoint(         dstrect[0] - 1, dstrect[1] + dstrect[3])
    G.renderer.drawPoint(dstrect[0] + dstrect[2], dstrect[1] + dstrect[3])


## Helper functions
func padded*(rect: Rect, padding: cint): Rect =
    rect(rect[0] - padding, rect[1] - padding, rect[2] + 2 * padding, rect[3] + 2 * padding)

