## Local imports
import globals
import types
import sdl_wrapper

## Library imports
import sdl2

{.experimental: "codeReordering".}

### Handle events
proc onInput(input: Input) =
    case input.kind:
    of InputKind.Keydown:
        echo $input
        
        ## F11 -> Toggle Fullscreen
        if input.scancode == Scancode.SDL_SCANCODE_F11:
            G.is_screen_maximized = not G.is_screen_maximized
            setScreenDimensions(G.is_screen_maximized)
            updateWindowDimensions(G.is_screen_maximized)

        ## Ctrl C -> Quit
        if input.mod_ctrl and input.scancode == Scancode.SDL_SCANCODE_C:
            G.running = false
            echo "Quitting due to Ctrl + C..."

        ## Ctrl F -> Toggle Find
        if input.mod_ctrl and input.scancode == Scancode.SDL_SCANCODE_F:
            if G.focus_mode == FocusMode.Search:
                discard G.focus_stack.pop()
            else:
                G.focus_stack.add(FocusMode.Search)

        ## Ctrl N -> Pop up Creation Window
        if input.mod_ctrl and input.scancode == Scancode.SDL_SCANCODE_N:
            if G.focus_mode == FocusMode.CreationWindow:
                discard G.focus_stack.pop()
            else:
                G.focus_stack.add(FocusMode.CreationWindow)
            

        ## Typing
        if (G.focus_mode == FocusMode.Search or G.focus_mode == FocusMode.Text or G.focus_mode == FocusMode.CreationWindow) and input.is_displayable:
            var discard_character = false
            if G.focus_mode == FocusMode.Text and input.character == ' ':
                case G.current_text
                of "if":
                    discard G.texties.pop()
                    G.texties.add(Texty(text: "if", kind: Keyword))
                    G.texties.add(Texty(text: " ", kind: Spacing))
                    G.texties.add(Texty(text: "what", kind: Todo))
                    G.texties.add(Texty(text: " ", kind: Spacing))
                    G.texties.add(Texty(text: "then", kind: Keyword))
                    G.texties.add(Texty(text: " ", kind: Spacing))
                    G.texties.add(Texty(text: "", kind: Todo))
                    discard_character = true
                of "proc":
                    discard G.texties.pop()
                    G.texties.add(Texty(text: "proc", kind: Keyword))
                    G.texties.add(Texty(text: " ", kind: Spacing))
                    G.texties.add(Texty(text: "what", kind: Todo))
                    G.texties.add(Texty(text: "() -> ", kind: Punctuation))
                    G.texties.add(Texty(text: "type", kind: Todo))
                    G.texties.add(Texty(text: " =", kind: Punctuation))
                    G.texties.add(Texty(text: "\t\n", kind: Spacing))
                    G.texties.add(Texty(text: "", kind: Todo))
                    discard_character = true
                else:
                    discard
            if not discard_character:
                onTextChange(G.current_text & $input.character)

        elif input.scancode == SDL_SCANCODE_BACKSPACE:
            if G.current_text.len >= 1:
                onTextChange(G.current_text[0 ..< ^1])

        elif input.scancode == SDL_SCANCODE_RETURN:
            G.texties.add(Texty(text: "\n", kind: Spacing))
            G.texties.add(Texty(text: "", kind: Todo))

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

    of EventType.WindowEvent:
        echo $event.evWindow.event

    else:
        echo $event.kind
        discard


### Text events
proc onTextChange*(new_text: string) =
    case G.focus_mode
    of FocusMode.Search:
        G.current_search_term = new_text
    of FocusMode.Text:
        G.texties[^1].text = new_text
    of FocusMode.CreationWindow:
        G.creation_window_search = new_text
