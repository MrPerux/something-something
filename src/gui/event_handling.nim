## Local imports
import ../globals
import ../types
import sdl_wrapper
import ../language/autocomplete
import ../language/code_actions
import ../language/editables
import ../language/slices

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
                refreshSearch()

        ## Ctrl N -> Pop up Creation Window
        if input.mod_ctrl and input.scancode == Scancode.SDL_SCANCODE_N:
            if G.focus_mode == FocusMode.CreationWindow:
                discard G.focus_stack.pop()
            else:
                G.focus_stack.add(FocusMode.CreationWindow)

        ## Ctrl E -> Pop up Goto Window
        if input.mod_ctrl and input.scancode == Scancode.SDL_SCANCODE_E:
            if G.focus_mode == FocusMode.GotoWindow:
                discard G.focus_stack.pop()
            else:
                G.focus_stack.add(FocusMode.GotoWindow)

        ## Ctrl S -> Cycle Font
        if input.mod_ctrl and input.scancode == Scancode.SDL_SCANCODE_S:
            G.switchable_fonts.insert(G.switchable_fonts.pop, 0)
            G.standard_font = G.switchable_fonts[0]

        ## Ctrl J -> Next Item
        if input.mod_ctrl and input.scancode == Scancode.SDL_SCANCODE_J:
            ## Creation Window
            if G.focus_mode == FocusMode.CreationWindow:
                if G.creation_window_selection_index + 1 < G.creation_window_selection_options.len:
                    G.creation_window_selection_index += 1
            
            ## Text
            if G.focus_mode == FocusMode.Text and G.optionally_selected_editable.isSome:
                let new_editable = maybeNextEditableLeaveSoUnparsedRightNow(G.optionally_selected_editable.get())
                if new_editable.isSome:
                    changeOptionallySelectedEditable(new_editable)
                    echo fmt"New editable: {new_editable.get()}"

        ## Ctrl K -> Previous Item
        if input.mod_ctrl and input.scancode == Scancode.SDL_SCANCODE_K:
            ## Creation Window
            if G.focus_mode == FocusMode.CreationWindow:
                if G.creation_window_selection_index - 1 >= 0:
                    G.creation_window_selection_index -= 1

            ## Text
            if G.focus_mode == FocusMode.Text and G.optionally_selected_editable.isSome:
                let new_editable = maybePreviousEditableLeaveSoUnparsedRightNow(G.optionally_selected_editable.get())
                if new_editable.isSome:
                    changeOptionallySelectedEditable(new_editable)
                    echo fmt"New editable: {new_editable.get()}"

        ## Typing
        if input.is_displayable:
            onTextChange(G.current_text & $input.character)

        elif input.scancode == SDL_SCANCODE_BACKSPACE:
            if G.current_text.len > 0:
                case input.mod_ctrl
                of true:
                    onTextChange("")
                of false:
                    onTextChange(G.current_text[0 ..< ^1])
            else:
                maybeDeleteCurrentLineInParentBody()

        elif input.scancode == SDL_SCANCODE_RETURN:
            case G.focus_mode
            of FocusMode.Text:
                if G.optionally_selected_editable.isSome:
                    handleNewline()
            of FocusMode.CreationWindow:
                let keyword_option = G.creation_window_selection_options[G.creation_window_selection_index]
                handleKeywordOption(keyword_option)
                onTextChange("")
                discard G.focus_stack.pop()
                # case creation_option.text
                # of "proc":
                #     addTodoProcedureAndSwitch()
                #     should_clear_search_text_and_close_window = true
                # of "if then":
                #     addIfStatementAndSwitch()
                #     should_clear_search_text_and_close_window = true
                # of "comment (#)":
                #     addCommentAndSwitch()
                #     should_clear_search_text_and_close_window = true
                # else:
                #     discard
            of FocusMode.GotoWindow:
                discard
            of FocusMode.Search:
                discard

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


### Text events
proc onTextChange*(new_text: string) =
    case G.focus_mode
    of FocusMode.Search:
        G.current_search_term = new_text
        refreshSearch()

    of FocusMode.Text:
        if G.optionally_selected_editable.isSome and G.optionally_selected_editable.get() of EditableUnparsed:
            var editable_unparsed = cast[EditableUnparsed](G.optionally_selected_editable.get())
            editable_unparsed.value = new_text
            assert G.optional_writing_context.isSome

            ## Keyword
            if G.optional_writing_context.get().keywords.contains(new_text):
                let thingy = G.optional_writing_context.get().keywords[new_text]
                let keyword_option = (new_text, thingy[0], thingy[1])
                handleKeywordOption(keyword_option)
            
            ## Operator
            for operator in G.optional_writing_context.get().operators.keys:
                if new_text.endsWith(operator):
                    let thingy = G.optional_writing_context.get().operators[operator]
                    let keyword_option = (new_text, thingy[0], thingy[1])
                    let lhs_string = new_text.substr(0, new_text.len - operator.len - 1)
                    if lhs_string.len > 0:
                        let lhs = initEditableUnparsed(lhs_string) ## TODO: Parse into valid identifier?
                        let rhs = initEditableUnparsed(operator) ## TODO: Parse into valid identifier?
                        var wrapper = initEditableExpressionWithSuffixWriting(cast[Editable](lhs), rhs)
                        replaceWith(G.optionally_selected_editable.get(), cast[Editable](wrapper))
                        changeOptionallySelectedEditable(some(cast[Editable](rhs)))
                        echo "Just did crazy splitting stuff!"
                    echo "Doing handleKeywordOption for operator"
                    echo "current selected: " & $G.optionally_selected_editable.get()
                    echo "its parent: " & $G.optionally_selected_editable.get().parent
                    echo "and its parent: " & $G.optionally_selected_editable.get().parent.parent
                    handleKeywordOption(keyword_option)
                    break

    of FocusMode.CreationWindow:
        let last_selection = G.creation_window_selection_options[G.creation_window_selection_index]
        G.creation_window_search = new_text
        remakeCreationWindowSelectionOptions()
        var maybe_new_index: cint = -1
        for i in 0 ..< G.creation_window_selection_options.len:
            if G.creation_window_selection_options[i] == last_selection:
                maybe_new_index = cast[cint](i)
        if maybe_new_index == -1:
            G.creation_window_selection_index = min(cast[cint](G.creation_window_selection_options.len) - 1, G.creation_window_selection_index)
        else:
            G.creation_window_selection_index = maybe_new_index

    of FocusMode.GotoWindow:
        let last_selection = G.goto_window_selection_options[G.goto_window_selection_index]
        G.goto_window_search = new_text
        remakeGotoWindowSelectionOptions()
        var maybe_new_index: cint = -1
        for i in 0 ..< G.goto_window_selection_options.len:
            if G.goto_window_selection_options[i].text == last_selection.text:
                maybe_new_index = cast[cint](i)
        if maybe_new_index == -1:
            G.goto_window_selection_index = min(cast[cint](G.goto_window_selection_options.len) - 1, G.goto_window_selection_index)
        else:
            G.goto_window_selection_index = maybe_new_index
