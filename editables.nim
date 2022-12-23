## Local imports
import globals
import types

## Library imports
import std/options

### Editable Code
method textyIterator*(x: Editable, texties: var seq[Texty]) {.base.} = discard

## Unparsed
method textyIterator*(x: EditableUnparsed, texties: var seq[Texty]) =
    if G.optionally_selected_editable.isSome and G.optionally_selected_editable.get() == x:
        texties.add(Texty(text: x.value, kind: CurrentlyTyping, currently_typing_kind: Unparsed))
    else:
        texties.add(Texty(text: x.value, kind: Unparsed))

proc initEditableUnparsed*(value: string): EditableUnparsed =
    result = EditableUnparsed(value: value)

## Parameters
method textyIterator*(x: EditableParameters, texties: var seq[Texty]) =
    texties.add(Texty(text: "(", kind: Punctuation))
    var is_first = true
    for value in x.parameters_unparsed:
        if not is_first:
            texties.add(Texty(text: ", ", kind: Punctuation))
        textyIterator(value, texties)
        is_first = false
    texties.add(Texty(text: ")", kind: Punctuation))

proc initEditableParameters*(parameters_unparsed: seq[EditableUnparsed]): EditableParameters =
    result = EditableParameters(parameters_unparsed: parameters_unparsed)
    for value in parameters_unparsed:
        value.parent = result


## Body
method textyIterator*(x: EditableBody, texties: var seq[Texty]) =
    texties.add(Texty(text: "\t\n", kind: Spacing))
    for value in x.lines:
        textyIterator(value, texties)
        texties.add(Texty(text: "\n", kind: Spacing))
    texties.add(Texty(text: "\r", kind: Spacing))

proc initEditableBody*(lines: seq[Editable]): EditableBody =
    result = EditableBody(lines: lines)
    for value in lines:
        value.parent = result

## Procedure Definition

method textyIterator*(x: EditableProcedureDefinition, texties: var seq[Texty]) =
    texties.add(Texty(text: "proc", kind: Keyword))
    texties.add(Texty(text: " ", kind: Spacing))
    textyIterator(x.name, texties)
    textyIterator(x.parameters, texties)
    texties.add(Texty(text: " ", kind: Spacing))
    texties.add(Texty(text: "=", kind: Punctuation))
    textyIterator(x.body, texties)

proc initEditableProcedureDefinition*(name: EditableUnparsed, parameters: EditableParameters, body: EditableBody): EditableProcedureDefinition =
    result = EditableProcedureDefinition(name: name, parameters: parameters, body: body)
    name.parent = result
    parameters.parent = result
    body.parent = result
