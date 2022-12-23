## Local imports

## Library imports
import sdl2
import std/strformat

# {.experimental: "codeReordering".}

### 2D position object
type Pos* = object
    x*: cint
    y*: cint

func pos*(x: cint, y: cint): Pos =
    Pos(x: x, y: y)

proc `+`*(a: Pos, b: Pos): Pos =
    pos(a.x + b.x, a.y + b.y)
proc `-`*(a: Pos, b: Pos): Pos =
    pos(a.x - b.x, a.y - b.y)


### Input
type InputKind* = enum
    Keydown
    None

type Input* = object
    case kind*: InputKind:
    of Keydown:
        is_displayable*: bool
        character*: char
        scancode*: Scancode
        mod_shift*: bool
        mod_ctrl*: bool
        mod_alt*: bool
    of None:
        nil


### Text Kind
type TextKind* = enum
    CurrentlyTyping
    Todo
    Unparsed # TODO: Parse stuff and remove this :)
    Spacing
    Keyword
    Type
    Literal
    Punctuation


type Texty* = ref object
    text*: string
    case kind*: TextKind
    of CurrentlyTyping:
        currently_typing_kind*: TextKind
    of Todo:
        todo_kind*: TextKind
    else: 
        discard

func `$`*(x: Texty): string =
    fmt"<{x.kind}:{x.text}>"


type NamedTextyLine* = object
    name*: string
    texties*: seq[Texty]

func initNamedTextyLine*(name: string, texties: seq[Texty]): NamedTextyLine =
    NamedTextyLine(name: name, texties: texties)

func `$`*(x: NamedTextyLine): string =
    fmt"({x.name}:{x.texties})"


### Focus
type FocusMode* = enum
    Text
    Search
    CreationWindow
    GotoWindow


### Editable Code
type Editable* = ref object of RootObj
    is_selected*: bool
    parent*: Editable

method textyIterator*(x: Editable): seq[Texty] {.base.} = discard

## Unparsed
type EditableUnparsed* = ref object of Editable
    value*: string

method textyIterator*(x: EditableUnparsed): seq[Texty] =
    if x.is_selected:
        result.add(Texty(text: x.value, kind: CurrentlyTyping, currently_typing_kind: Unparsed))
    else:
        result.add(Texty(text: x.value, kind: Unparsed))

proc initEditableUnparsed*(value: string): EditableUnparsed =
    result = EditableUnparsed(value: value)

## Parameters
type EditableParameters* = ref object of Editable
    parameters_unparsed*: seq[EditableUnparsed] # TODO: Turn into optionally typed identifiers

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
type EditableBody* = ref object of Editable
    lines*: seq[Editable]

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
type EditableProcedureDefinition* = ref object of Editable
    name*: EditableUnparsed # TODO: Turn into an editable identifier
    parameters*: EditableParameters
    body*: EditableBody

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
