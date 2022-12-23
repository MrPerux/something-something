## Local imports
import globals
import types

## Library imports
import std/options

### Editable Code
method textyIterator*(x: Editable): seq[Texty] {.base.} = discard

## Unparsed
method textyIterator*(x: EditableUnparsed): seq[Texty] =
    if G.optionally_selected_editable.isSome and G.optionally_selected_editable.get() == x:
        result.add(Texty(text: x.value, kind: CurrentlyTyping, currently_typing_kind: Unparsed))
    else:
        result.add(Texty(text: x.value, kind: Unparsed))

proc initEditableUnparsed*(value: string): EditableUnparsed =
    result = EditableUnparsed(value: value)

## Parameters
method textyIterator*(x: EditableParameters): seq[Texty] =
    result.add(Texty(text: "(", kind: Punctuation))
    var is_first = true
    for value in x.parameters_unparsed:
        if not is_first:
            result.add(Texty(text: ", ", kind: Punctuation))
        for t in textyIterator(value):
            result.add(t)
        is_first = false
    result.add(Texty(text: ")", kind: Punctuation))

proc initEditableParameters*(parameters_unparsed: seq[EditableUnparsed]): EditableParameters =
    result = EditableParameters(parameters_unparsed: parameters_unparsed)
    for value in parameters_unparsed:
        value.parent = result


## Body
method textyIterator*(x: EditableBody): seq[Texty] =
    result.add(Texty(text: "\t\n", kind: Spacing))
    for value in x.lines:
        for t in textyIterator(value):
            result.add(t)
        result.add(Texty(text: "\n", kind: Spacing))
    result.add(Texty(text: "\r", kind: Spacing))

proc initEditableBody*(lines: seq[Editable]): EditableBody =
    result = EditableBody(lines: lines)
    for value in lines:
        value.parent = result

## Procedure Definition

method textyIterator*(x: EditableProcedureDefinition): seq[Texty] =
    result.add(Texty(text: "proc", kind: Keyword))
    result.add(Texty(text: " ", kind: Spacing))
    for t in textyIterator(x.name):
        result.add(t)
    for t in textyIterator(x.parameters):
        result.add(t)
    result.add(Texty(text: " ", kind: Spacing))
    result.add(Texty(text: "=", kind: Punctuation))
    for t in textyIterator(x.body):
        result.add(t)

proc initEditableProcedureDefinition*(name: EditableUnparsed, parameters: EditableParameters, body: EditableBody): EditableProcedureDefinition =
    result = EditableProcedureDefinition(name: name, parameters: parameters, body: body)
    name.parent = result
    parameters.parent = result
    body.parent = result
