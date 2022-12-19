## Local imports
import globals

## Library imports
import sdl2
import sdl2/ttf
import types
import std/tables


### SDL Exceptions
type SDLException = object of Defect

template sdlFailIf*(condition: typed, reason: string) =
    if condition: raise SDLException.newException(
        reason & ", SDL error " & $getError()
    )


### Text Helper
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
        G.fonts[font_size] = ttf.openFont("assets/Hack Regular Nerd Font Complete.ttf", font_size)
        sdlFailIf G.fonts[font_size].isNil: "font could not be created"
    drawText(G.fonts[font_size], text, color, x, y)

## Optimized Text Rendering with Texture Atlas
proc initTextureAtlasStandardSize*() =
    ## Load font
    let font = ttf.openFont("assets/Hack Regular Nerd Font Complete.ttf", 16)
    sdlFailIf font.isNil: "font could not be created"
    G.fonts[16] = font

    ## Create atlas surface
    const
        glyph_width = 10
        glyph_height = 20
        number_of_glyphs = 127
    var atlas_surf = createRGBSurface(0, glyph_width * number_of_glyphs, glyph_height * 1, 32, 0x000000FFu32, 0x0000FF00u32, 0x00FF0000u32, 0xFF000000u32)
    var atlas_rect = rect(0, 0, glyph_width * number_of_glyphs, glyph_height)
    atlas_surf.fillRect(addr atlas_rect, 0x00ffffffu32)

    ## Rendering glyphs
    for c in 33..<number_of_glyphs:
        # if c mod 5 == 1:
        #     continue
        let surface = ttf.renderTextBlended(font, cstring($cast[char](c)), color(255, 255, 255, 255))
        var destination = rect(
            cast[cint](c * glyph_width),
            0)
        # sdlFailIf setSurfaceBlendMode(surface, BlendMode_Blend) != 0:
        #     "blend mode"
        surface.blitSurface(nil, atlas_surf, addr destination)
    
    ## Store result
    G.texture_atlas_standard_size = G.renderer.createTextureFromSurface(atlas_surf)

    ## Clean up
    atlas_surf.freeSurface() ## TODO: Should this be freed?

proc drawStandardSizeTextFast*(text: cstring, color: Color, x: cint, y: cint) =
    ## Set color
    sdlFailIf setTextureColorMod(G.texture_atlas_standard_size, color[0], color[1], color[2]) != SdlSuccess:
        "Cannot set texture color mod for colored text rendering"
    
    ## Blit every character from font texture atlas
    const
        glyph_width = 10
        glyph_height = 20
    var current_x = x
    for c in text:
        var source_rect = rect(cast[cint](c) * glyph_width, 0, glyph_width, glyph_height)
        var destination_rect = rect(current_x, y, glyph_width, glyph_height)
        G.renderer.copy(G.texture_atlas_standard_size, addr source_rect, addr destination_rect)
        current_x += glyph_width


### Input Handling
const
    MOD_SHIFT = KMOD_LSHIFT or KMOD_RSHIFT
    MOD_CTRL = KMOD_LCTRL or KMOD_RCTRL
    MOD_ALT = KMOD_LALT or KMOD_RALT

func isDisplayableAsciiCharacterMap(): array[0..127, bool] =
    for c in " qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890!@#$%^&*()_+~`-=[]\\;',./{}|:\"<>?":
        result[cast[cint](c)] = true

func toInput*(c: char, mod_state: Keymod): Input =
    const table = isDisplayableAsciiCharacterMap()
    if cast[cint](c) in 0..127 and table[cast[cint](c)]:
        Input(kind: InputKind.Keydown, is_ascii: true, character: c, scancode: cast[Scancode](0), mod_shift: bool(mod_state and
                MOD_SHIFT), mod_ctrl: bool(mod_state and MOD_CTRL), mod_alt: bool(mod_state and MOD_ALT))
    else:
        Input(kind: None)

func toInput*(key: Scancode, mod_state: Keymod): Input =
    Input(kind: InputKind.Keydown, is_ascii: false, character: cast[char](0), scancode: key, mod_shift: bool(mod_state and
            MOD_SHIFT), mod_ctrl: bool(mod_state and MOD_CTRL), mod_alt: bool(mod_state and MOD_ALT))

