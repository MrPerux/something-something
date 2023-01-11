## Local imports
import ../types
import ../globals

## Library imports
import os
import sdl2

## Standard imports
{. warning[UnusedImport]:off .}
import sugar
import std/tables
import std/strutils
import std/options
import std/strformat
import system/dollars

### SDL Exceptions
type SDLException = object of Defect

template sdlFailIf*(condition: typed, reason: string) =
    if condition: raise SDLException.newException(
        reason & ", SDL error " & $getError()
    )
template sdlAssertSuccess*(condition: typed) =
    if condition != SdlSuccess: raise SDLException.newException("SDL error " & $getError())


### Fullscreen toggler
proc setScreenDimensions*(maximized_mode: bool) =
    const MONITOR_WIDTH = if existsEnv("WSL_INTEROP"): 2560 else: 1920
    const MONITOR_HEIGHT = if existsEnv("WSL_INTEROP"): 1440 else: 1053

    if maximized_mode:
        G.width = MONITOR_WIDTH
        G.height = MONITOR_HEIGHT
    else:
        G.width = 600
        G.height = 400

proc updateWindowDimensions*() =
    G.window.setSize(G.width, G.height)
    G.window.setPosition(SDL_WINDOWPOS_CENTERED, 0)
    G.window.raiseWindow


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
        Input(kind: InputKind.Keydown, is_displayable: not bool(mod_state and MOD_ALT), character: c, scancode: cast[Scancode](0), mod_shift: bool(mod_state and
                MOD_SHIFT), mod_ctrl: bool(mod_state and MOD_CTRL), mod_alt: bool(mod_state and MOD_ALT))
    else:
        Input(kind: None)

func toInput*(key: Scancode, mod_state: Keymod): Input =
    Input(kind: InputKind.Keydown, is_displayable: false, character: cast[char](0), scancode: key, mod_shift: bool(mod_state and
            MOD_SHIFT), mod_ctrl: bool(mod_state and MOD_CTRL), mod_alt: bool(mod_state and MOD_ALT))

