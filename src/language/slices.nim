## Local imports
import ../types
import ../globals
import editables

## Library imports

## Standard imports
{. warning[UnusedImport]:off .}
import sugar
import std/tables
import std/strutils
import std/options
import std/strformat
import system/dollars


### Slices
proc sliceWithFilter(editables: seq[Editable], filter: Filter): EditableBody =
    var filtered: seq[Editable] = @[]

    case filter.kind
    of FilterOnName:
        for editable in editables:
            var maybeName: Option[string]
            ## TODO: Make function
            if editable of EditableProcedureDefinition:
                maybeName = some(cast[EditableProcedureDefinition](editable).name.value)

            if maybeName.isSome and maybeName.get().startswith(filter.name_to_filter):
                filtered.add(editable)

    of FilterOnType:
        for editable in editables:
            let is_good = case filter.type_to_filter
                of FunctionDefition: editable of EditableProcedureDefinition
                of TypeDefinition: false
            if is_good:
                filtered.add(editable)

    of FilterOnNumberOfLinesInFunctionBody:
        for editable in editables:
            if editable of EditableProcedureDefinition and cast[EditableProcedureDefinition](editable).body.lines.len >= filter.at_least_n_lines:
                filtered.add(editable)

    initEditableBody(filtered)

proc updateCurrentSliceFilter*() =
    G.current_slice = sliceWithFilter(G.all_editables, G.current_slice_filter)

proc refreshSearch*() =
    G.current_slice_filter = Filter(kind: FilterOnName, name_to_filter: G.current_search_term)
    updateCurrentSliceFilter()
