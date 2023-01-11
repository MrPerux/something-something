## Local imports
import globals
import types

## Library imports
import std/options
import std/tables
import std/strutils
import std/strformat

### Autocompletion
proc remakeCreationWindowSelectionOptions*() =
    G.creation_window_selection_options = @[]
    if not G.optional_writing_context.isSome:
        return
    for name, (keyword, description) in G.optional_writing_context.get().keywords:
        if name.startswith(G.creation_window_search):
            G.creation_window_selection_options.add((name, keyword, description))
    if G.creation_window_selection_options.len == 0:
        G.creation_window_selection_options.add(("_____", FillerSoThingWontBeEmpty, "~~"))

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
