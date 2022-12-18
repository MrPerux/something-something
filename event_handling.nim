## Local imports
import globals
import types
import sdl_wrapper

## Library imports
import sdl2


### Handle events
proc onInput(input: Input) =
    case input.kind:
    of InputKind.Keydown:
        echo $input
        
        if input.mod_ctrl and input.scancode == Scancode.SDL_SCANCODE_C:
            G.running = false
            echo "Quitting due to Ctrl + C..."

    of None:
        discard

proc handleEvent*(event: Event) =
    case event.kind
    of QuitEvent:
        G.running = false

    of TextInput:
        let c = event.evTextInput.text[0]
        onInput(toInput(c, getModState()))

    of EventType.KeyDown:
        onInput(toInput(event.evKeyboard.keysym.scancode, cast[Keymod](event.evKeyboard.keysym.modstate)))

    of EventType.MouseButtonDown:
        echo "Click!"

    else:
        discard
