## Local imports
import globals
import types
import editables

## Library imports
import std/options

{.experimental: "codeReordering".}

### Code actions for adding code
proc addTodoProcedureAndSwitch*() =
    var procedure = initEditableProcedureDefinition(
        initEditableUnparsed("proc2"),
        initEditableParameters(@[initEditableUnparsed("param1"), initEditableUnparsed("param2")]),
        initEditableBody(@[cast[Editable](initEditableUnparsed("whoop whoop")), cast[Editable](initEditableUnparsed("Noice"))]))
    G.optionally_selected_editable = some(cast[Editable](procedure.name))
    G.texty_lines.add(initNamedTextyLine(procedure.name.value, procedure))

proc addIfStatementAndSwitch*() =
    discard ## TODO
proc addCommentAndSwitch*() =
    discard ## TODO
