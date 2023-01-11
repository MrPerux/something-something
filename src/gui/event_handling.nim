## Local imports
import ../globals
import ../types
import lib_sdl

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

{.experimental: "codeReordering".}

### Handle events
proc onInput(input: Input) =
    case input.kind:
    of InputKind.Keydown:        
        ## F11 or Alt F -> Toggle Fullscreen
        if input.scancode == Scancode.SDL_SCANCODE_F11 or (input.mod_alt and input.scancode == Scancode.SDL_SCANCODE_F):
            G.is_screen_maximized = not G.is_screen_maximized
            setScreenDimensions(G.is_screen_maximized)
            updateWindowDimensions()

        ## Ctrl C -> Quit
        if input.mod_ctrl and input.scancode == Scancode.SDL_SCANCODE_C:
            G.running = false
            echo "Quitting due to Ctrl + C..."

        ## Ctrl D -> Debug Mode
        if input.mod_ctrl and input.scancode == Scancode.SDL_SCANCODE_D:
            G.debug_mode = not G.debug_mode

        ## Ctrl F -> Toggle Find
        if input.mod_ctrl and input.scancode == Scancode.SDL_SCANCODE_F:
            if G.focus_mode == FocusMode.Search:
                discard G.focus_stack.pop()
            else:
                G.focus_stack.add(FocusMode.Search)

        ## Ctrl S -> Cycle Font
        if input.mod_ctrl and input.scancode == Scancode.SDL_SCANCODE_S:
            G.switchable_fonts.insert(G.switchable_fonts.pop, 0)
            G.standard_font = G.switchable_fonts[0]

        # ## Typing
        # if input.is_displayable:
        #     onTextChange(G.current_text & $input.character)

        # elif input.scancode == SDL_SCANCODE_BACKSPACE:

        # elif input.scancode == SDL_SCANCODE_RETURN:

    of None:
        discard

proc handleEvent*(event: Event) =
    case event.kind
    of QuitEvent:
        G.running = false

    of TextInput:
        # echo fmt"TextInput(text: {$event.evTextInput.text}, {$event.evTextInput.timestamp})"
        let c = event.evTextInput.text[0]
        onInput(toInput(c, getModState()))

    of EventType.KeyDown:
        # echo fmt"Scancode({$event.evKeyboard.keysym.scancode})"
        onInput(toInput(event.evKeyboard.keysym.scancode, cast[Keymod](event.evKeyboard.keysym.modstate)))

    # of EventType.MouseButtonDown:
    #     echo "Click!"

    of EventType.WindowEvent:
        discard
    #     echo $event.evWindow.event

    else:
        # echo $event.kind
        discard

