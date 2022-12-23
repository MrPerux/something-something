## Local imports
import globals
import types

## Library imports
import std/strutils
import std/strformat

### Autocompletion
proc remakeCreationWindowSelectionOptions*() =
    G.creation_window_selection_options = @[]
    if startswith("def", G.creation_window_search) or startswith("proc", G.creation_window_search) or startswith("func", G.creation_window_search):
        G.creation_window_selection_options.add(Texty(text: "proc", kind: Keyword))
    if startswith("if", G.creation_window_search):
        G.creation_window_selection_options.add(Texty(text: "if then", kind: Keyword))
    if startswith("#", G.creation_window_search):
        G.creation_window_selection_options.add(Texty(text: "comment (#)", kind: Todo))
    G.creation_window_selection_options.add(Texty(text: "second to last", kind: Todo))
    G.creation_window_selection_options.add(Texty(text: "the last", kind: Todo))
    if G.creation_window_selection_options.len == 2:
        G.creation_window_selection_options.add(Texty(text: fmt"create '{G.creation_window_search}'", kind: Literal))

proc remakeGotoWindowSelectionOptions*() =
    G.goto_window_selection_options = @[]
    if startswith("def", G.goto_window_search) or startswith("proc", G.goto_window_search) or startswith("func", G.goto_window_search):
        G.goto_window_selection_options.add(Texty(text: "All procedures", kind: Keyword))
    if startswith("if", G.goto_window_search):
        G.goto_window_selection_options.add(Texty(text: "All ifs", kind: Keyword))
    if startswith("#", G.goto_window_search):
        G.goto_window_selection_options.add(Texty(text: "All comments", kind: Todo))
    G.goto_window_selection_options.add(Texty(text: "type u32", kind: Todo))
    G.goto_window_selection_options.add(Texty(text: "proc insert()", kind: Todo))
