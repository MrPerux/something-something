## Local imports

## Library imports
import sdl2
import sdl2/ttf
import types


### SDL Exceptions
type SDLException = object of Defect

template sdlFailIf*(condition: typed, reason: string) =
    if condition: raise SDLException.newException(
        reason & ", SDL error " & $getError()
    )


### Text Helper
proc drawText*(renderer: RendererPtr, font: FontPtr, text: cstring,
        color: Color, x: cint, y: cint) =
    if text.len == 0:
        return
    let
        surface = ttf.renderTextBlended(font, text, color)
        texture = renderer.createTextureFromSurface(surface)

    surface.freeSurface
    defer: texture.destroy

    var r = rect(
        x,
        y,
        surface.w,
        surface.h
    )
    renderer.copy texture, nil, addr r


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

