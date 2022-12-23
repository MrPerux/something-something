## Local imports
import globals
import types

## Library imports

### Code actions for adding code
proc addTodoProcedure*() =
    G.texty_lines.add(initNamedTextyLine("todoProc#1", @[
        Texty(text: "proc", kind: Keyword),
        Texty(text: " ", kind: Spacing),
        Texty(text: "what", kind: Todo),
        Texty(text: "() -> ", kind: Punctuation),
        Texty(text: "type", kind: Todo),
        Texty(text: " =", kind: Punctuation),
        Texty(text: "\t\n", kind: Spacing),
        Texty(text: "", kind: Todo)]))

proc addIfStatement*() =
    G.texty_lines[^1].texties.add(Texty(text: "if", kind: Keyword))
    G.texty_lines[^1].texties.add(Texty(text: " ", kind: Spacing))
    G.texty_lines[^1].texties.add(Texty(text: "what", kind: Todo))
    G.texty_lines[^1].texties.add(Texty(text: " ", kind: Spacing))
    G.texty_lines[^1].texties.add(Texty(text: "then", kind: Keyword))
    G.texty_lines[^1].texties.add(Texty(text: " ", kind: Spacing))
    G.texty_lines[^1].texties.add(Texty(text: "", kind: Todo))

proc addComment*() =
    G.texty_lines[^1].texties.add(Texty(text: "# ", kind: Keyword))
    G.texty_lines[^1].texties.add(Texty(text: "", kind: Todo))
