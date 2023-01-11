## Local imports
import ../types
import colors
import ../globals
import sdl_wrapper
import drawing_helper

## Library imports
import sdl2
import sdl2/ttf

## Standard imports
{. warning[UnusedImport]:off .}
import sugar
import std/tables
import std/strutils
import std/options
import std/strformat
import system/dollars

### Text Rendering
const CODE_FONT_PATH = "assets/Consolas Monospace Font Regular.ttf"
# const CODE_FONT_PATH = "assets/Hack Regular Nerd Font Complete.ttf"
# const CODE_FONT_PATH = "assets/Consolas Monospace Font Bold.ttf"

proc drawTextWithoutAtlas(font: FontPtr, text: string, color: Color, x: cint, y: cint) =
    if text.len == 0:
        return
    let
        surface = ttf.renderTextBlended(font, cstring(text), color)
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

proc drawTextWithoutAtlas*(font_path: string, font_size: cint, text: string, color: Color, x: cint, y: cint) =
    if not G.fonts.hasKey(font_size):
        G.fonts[font_size] = ttf.openFont(font_path, font_size)
        sdlFailIf G.fonts[font_size].isNil: "font could not be created"
    drawTextWithoutAtlas(G.fonts[font_size], text, color, x, y)


## Optimized Text Rendering with Texture Atlas
proc initFontInfo*(font_path: string, glyph_size: cint, glyph_x_stride: cint, glyph_y_stride: cint, glyph_atlas_width: cint, glyph_atlas_height: cint): FontInfo =
    ## Load font
    let font = ttf.openFont(font_path, glyph_size)
    sdlFailIf font.isNil: "font could not be created"
    G.fonts[16] = font

    ## Create atlas surface
    const number_of_glyphs = 127
    var atlas_surf = createRGBSurface(0, glyph_atlas_width * number_of_glyphs, glyph_atlas_height * 1, 32, 0x000000FFu32, 0x0000FF00u32, 0x00FF0000u32, 0xFF000000u32)
    var atlas_rect = rect(0, 0, glyph_atlas_width * number_of_glyphs, glyph_atlas_height)
    atlas_surf.fillRect(addr atlas_rect, 0x00ffffffu32)

    ## Rendering glyphs
    for c in 33..<number_of_glyphs:
        let surface = ttf.renderTextBlended(font, cstring($cast[char](c)), color(255, 255, 255, 255))
        var destination = rect(
            cast[cint](c * glyph_atlas_width),
            0)
        surface.blitSurface(nil, atlas_surf, addr destination)
    
    ## Store result
    let texture = G.renderer.createTextureFromSurface(atlas_surf)
    result = FontInfo(
        texture: texture,
        glyph_size: glyph_size,
        glyph_baseline_y: font.fontAscent,
        glyph_x_stride: glyph_x_stride, glyph_y_stride: glyph_y_stride,
        glyph_atlas_width: glyph_atlas_width, glyph_atlas_height: glyph_atlas_height,
    )

    ## Clean up
    atlas_surf.freeSurface() ## TODO: Should this be freed?

proc easyMakeFont*(font_path: string, size_in_pixels: cint): FontInfo =
    initFontInfo(
        font_path = font_path,
        glyph_size = size_in_pixels,
        glyph_x_stride = size_in_pixels * 54 div 100 + 1, # 20 -> 11,  # 14 -> 8,   # 100 -> 55
        glyph_y_stride = size_in_pixels * 4 div 3 + 1, # 20 -> 27,  # 14 -> 19,  # 100 -> 134
        glyph_atlas_width = size_in_pixels * 54 div 100 + 1,
        glyph_atlas_height = size_in_pixels,
    )

proc initTextureAtlasStandardSize*() =
    G.switchable_fonts = @[
        easyMakeFont(CODE_FONT_PATH, 20),
        easyMakeFont(CODE_FONT_PATH, 14),
    ]
    G.standard_font = G.switchable_fonts[0]

proc drawHalfSizeHexCharacter(font: FontInfo, c: char, x: cint, y: cint) =
    var source_rect = rect(cast[cint](c) * font.glyph_atlas_width, 0, font.glyph_atlas_width, font.glyph_atlas_height)
    var destination_rect = rect(x, y, font.glyph_atlas_width, font.glyph_atlas_height div 2)
    G.renderer.copy(font.texture, addr source_rect, addr destination_rect)
    discard

proc drawTextFast*(font: FontInfo, text: string, color: Color, x: cint, y: cint) =
    ## Set color
    sdlFailIf setTextureColorMod(font.texture, color[0], color[1], color[2]) != SdlSuccess:
        "Cannot set texture color mod for colored text rendering"
    
    # ## Debug drawing
    # drawFilledRect(brightYellow, rect(x, y, font.glyph_x_stride * cast[cint](text.len), font.glyph_size))
    # drawFilledRect(brightPurple, rect(x, y + font.glyph_baseline_y, font.glyph_x_stride * cast[cint](text.len), font.glyph_size - font.glyph_baseline_y))

    ## Blit every character from font texture atlas
    var current_x = x
    for c in text:
        if c < ' ' or cast[cint](c) >= 127:
            ## Draw hex code in box
            drawOutlinedRect(color, rect(current_x, y, font.glyph_x_stride, font.glyph_size))
            let hex_code = cast[int](c).toHex(2)
            drawHalfSizeHexCharacter(font, hex_code[0], current_x, y)
            drawHalfSizeHexCharacter(font, hex_code[1], current_x, y + font.glyph_size div 2)
            current_x += font.glyph_x_stride
            continue
        var source_rect = rect(cast[cint](c) * font.glyph_atlas_width, 0, font.glyph_atlas_width, font.glyph_atlas_height)
        var destination_rect = rect(current_x, y, font.glyph_atlas_width, font.glyph_atlas_height)
        G.renderer.copy(font.texture, addr source_rect, addr destination_rect)
        current_x += font.glyph_x_stride

proc drawTextFastAlign*(font: FontInfo, text: string, color: Color, x: cint, y: cint, align_x: static[TextAlignment], align_y: static[TextAlignment]) {.inline.} =
    let xx = case align_x
        of Left: x
        of Center: x - font.glyph_x_stride * cast[cint](text.len) div 2
        of Right: x - font.glyph_x_stride * cast[cint](text.len)
    let yy = case align_y
        of Top: y
        of Center: y - font.glyph_size div 2 + font.glyph_size div 10
        of Bottom: y - font.glyph_size

    drawTextFast(font, text, color, xx, yy)
