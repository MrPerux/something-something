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
    G.all_editables.add(procedure)
    G.current_slice.lines.add(procedure) ## TODO: should we update filter?
    
    procedure.parent = G.current_slice
    G.optionally_selected_editable = some(cast[Editable](procedure.name))

proc addTopLevelSmallProcedureWithName*(name: string) =
    var procedure = initEditableProcedureDefinition(
        initEditableUnparsed(name),
        initEditableParameters(@[initEditableUnparsed("johan")]),
        initEditableBody(@[cast[Editable](initEditableUnparsed("..."))]))
    G.all_editables.add(procedure)
    G.current_slice.lines.add(procedure) ## TODO: should we update filter?
    procedure.parent = G.current_slice

proc addIfStatementAndSwitch*() =
    discard ## TODO
proc addCommentAndSwitch*() =
    discard ## TODO

## Removing code
proc maybeDeleteCurrentLineInParentBody*() =
    if G.optionally_selected_editable.isSome and not G.optionally_selected_editable.get().parent.isNil and G.optionally_selected_editable.get().parent of EditableBody:
        let to_remove = G.optionally_selected_editable.get()
        var body = cast[EditableBody](to_remove.parent)
        if body.lines.len > 1:
            let index = body.lines.find(to_remove)
            body.lines.delete(index)
            let new_index = if index < body.lines.len: index else: index - 1
            G.optionally_selected_editable = some(body.lines[new_index])

