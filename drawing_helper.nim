## Local imports
import globals
import sdl_wrapper
import types
import colors

## Library imports
import sdl2

### Drawing helper procs
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
