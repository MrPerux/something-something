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
        
        ## Ctrl C -> Quit
        if input.mod_ctrl and input.scancode == Scancode.SDL_SCANCODE_C:
            G.running = false
            echo "Quitting due to Ctrl + C..."

        ## Ctrl F -> Toggle Find
        if input.mod_ctrl and input.scancode == Scancode.SDL_SCANCODE_F:
            G.search_active = not G.search_active

        ## Typing in search box
        if G.search_active:
            if input.is_ascii:
                G.current_search_term.add(input.character)
            elif input.scancode == SDL_SCANCODE_BACKSPACE:
                if G.current_search_term.len >= 1:
                    G.current_search_term = G.current_search_term[0 ..< ^1]

        ## Texty typing
        if not G.search_active:
            if G.texties.len == 0 and input.is_ascii:
                G.texties.add(Texty(text: $input.character, kind: Todo))
            elif G.texties.len > 0:
                var current_texty = G.texties[^1]
                case current_texty.kind
                of Todo:
                    if input.is_ascii:
                        current_texty.text.add($input.character)
                    elif input.scancode == SDL_SCANCODE_BACKSPACE:
                        if current_texty.text.len >= 1:
                            current_texty.text = current_texty.text[0 ..< ^1]
                    case current_texty.text
                    of "if":
                        discard G.texties.pop()
                        G.texties.add(Texty(text: "if", kind: Keyword))
                        G.texties.add(Texty(text: " ", kind: Spacing))
                        G.texties.add(Texty(text: "what", kind: Todo))
                        G.texties.add(Texty(text: " ", kind: Spacing))
                        G.texties.add(Texty(text: "then", kind: Keyword))
                        G.texties.add(Texty(text: " ", kind: Spacing))
                        G.texties.add(Texty(text: "", kind: Todo))
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
                    else:
                        discard
                else:
                    echo "How are we typing on a nontypable field!?"
                    quit(1)

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
