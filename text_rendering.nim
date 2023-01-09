## Local imports
import types
import globals
import sdl_wrapper

## Library imports
import sdl2
import sdl2/ttf
import std/tables

### Text Rendering
const CODE_FONT_PATH = "assets/Hack Regular Nerd Font Complete.ttf"
# const CODE_FONT_PATH = "assets/Consolas Monospace Font Regular.ttf"
# const CODE_FONT_PATH = "assets/Consolas Monospace Font Bold.ttf"

proc drawText(font: FontPtr, text: cstring, color: Color, x: cint, y: cint) =
    if text.len == 0:
        return
    let
        surface = ttf.renderTextBlended(font, text, color)
        texture = G.renderer.createTextureFromSurface(surface)

    surface.freeSurface
    defer: texture.destroy

    var r = rect(
        x,
        y,
        surface.w,
        surface.h
    )
    G.renderer.copy texture, nil, addr r

proc drawText*(font_size: cint, text: cstring, color: Color, x: cint, y: cint) =
    if not G.fonts.hasKey(font_size):
        G.fonts[font_size] = ttf.openFont(CODE_FONT_PATH, font_size)
        sdlFailIf G.fonts[font_size].isNil: "font could not be created"
    drawText(G.fonts[font_size], text, color, x, y)

## Optimized Text Rendering with Texture Atlas
proc initFontInfo*(font_path: string, glyph_size: cint, glyph_x_stride: cint, glyph_y_stride: cint): FontInfo =
    ## Load font
    let font = ttf.openFont(CODE_FONT_PATH, glyph_size)
    sdlFailIf font.isNil: "font could not be created"
    G.fonts[16] = font

    ## Create atlas surface
    const number_of_glyphs = 127
    var atlas_surf = createRGBSurface(0, glyph_x_stride * number_of_glyphs, glyph_y_stride * 1, 32, 0x000000FFu32, 0x0000FF00u32, 0x00FF0000u32, 0xFF000000u32)
    var atlas_rect = rect(0, 0, glyph_x_stride * number_of_glyphs, glyph_y_stride)
    atlas_surf.fillRect(addr atlas_rect, 0x00ffffffu32)

    ## Rendering glyphs
    for c in 33..<number_of_glyphs:
        let surface = ttf.renderTextBlended(font, cstring($cast[char](c)), color(255, 255, 255, 255))
        var destination = rect(
            cast[cint](c * glyph_x_stride),
            0)
        surface.blitSurface(nil, atlas_surf, addr destination)
    
    ## Store result
    let texture = G.renderer.createTextureFromSurface(atlas_surf)
    result = FontInfo(
        texture: texture,
        glyph_size: glyph_size,
        glyph_x_stride: glyph_x_stride, glyph_y_stride: glyph_y_stride
    )

    ## Clean up
    atlas_surf.freeSurface() ## TODO: Should this be freed?

proc initTextureAtlasStandardSize*() =
    G.standard_font = initFontInfo(
        font_path = CODE_FONT_PATH,
        glyph_size = 16,
        glyph_x_stride = 10,
        glyph_y_stride = 20,
    )

proc drawStandardSizeTextFast*(text: cstring, color: Color, x: cint, y: cint) =
    ## Set color
    sdlFailIf setTextureColorMod(G.standard_font.texture, color[0], color[1], color[2]) != SdlSuccess:
        "Cannot set texture color mod for colored text rendering"
    
    ## Blit every character from font texture atlas
    let
        x_stride = G.standard_font.glyph_x_stride
        y_stride = G.standard_font.glyph_y_stride
    var current_x = x
    for c in text:
        if c <= ' ' or cast[cint](c) >= 127:
            current_x += x_stride
            continue
        var source_rect = rect(cast[cint](c) * x_stride, 0, x_stride, y_stride)
        var destination_rect = rect(current_x, y, x_stride, y_stride)
        G.renderer.copy(G.standard_font.texture, addr source_rect, addr destination_rect)
        current_x += x_stride
