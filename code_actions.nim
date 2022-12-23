## Local imports
import globals
import types

## Library imports

{.experimental: "codeReordering".}

### Code actions for adding code
proc addTodoProcedureAndSwitch*() =
    G.texty_lines.add(initNamedTextyLine("todoProc#1", @[
        Texty(text: "proc", kind: Keyword),
        Texty(text: " ", kind: Spacing),
        Texty(text: "what", kind: Todo, todo_kind: Literal),
        Texty(text: "() -> ", kind: Punctuation),
        Texty(text: "type", kind: Todo, todo_kind: Literal),
        Texty(text: " =", kind: Punctuation),
        Texty(text: "\t\n", kind: Spacing),
        Texty(text: "", kind: CurrentlyTyping, currently_typing_kind: Unparsed)]))

proc addIfStatementAndSwitch*() =
    G.texty_lines[^1].texties.add(Texty(text: "if", kind: Keyword))
    G.texty_lines[^1].texties.add(Texty(text: " ", kind: Spacing))
    G.texty_lines[^1].texties.add(Texty(text: "what", kind: Todo, todo_kind: Literal))
    G.texty_lines[^1].texties.add(Texty(text: " ", kind: Spacing))
    G.texty_lines[^1].texties.add(Texty(text: "then", kind: Keyword))
    G.texty_lines[^1].texties.add(Texty(text: " ", kind: Spacing))
    G.texty_lines[^1].texties.add(Texty(text: "", kind: CurrentlyTyping, currently_typing_kind: Unparsed))

proc addCommentAndSwitch*() =
    G.texty_lines[^1].texties.add(Texty(text: "# ", kind: Keyword))
    G.texty_lines[^1].texties.add(Texty(text: "", kind: CurrentlyTyping, currently_typing_kind: Keyword))


### Texty actions
proc switchTypingAwayFromCurrentTexty*() =
    G.texty_lines[^1].texties[^1] = Texty(text: G.current_texty.text, kind: G.current_texty.currently_typing_kind)

