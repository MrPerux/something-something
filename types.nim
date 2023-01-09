## Local imports

## Library imports
import sdl2
import std/strformat

{.experimental: "codeReordering".}

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
    Unparsed ## TODO: Parse stuff and remove this :)
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
    editable*: Editable

func initNamedTextyLine*(name: string, editable: Editable): NamedTextyLine =
    NamedTextyLine(name: name, editable: editable)

func `$`*(x: NamedTextyLine): string =
    fmt"({x.name}:...)"


### Focus
type FocusMode* = enum
    Text
    Search
    CreationWindow
    GotoWindow


### Editable Code
type Editable* = ref object of RootObj
    parent*: Editable

type EditableUnparsed* = ref object of Editable
    value*: string
    
type EditableParameters* = ref object of Editable
    parameters_unparsed*: seq[EditableUnparsed] ## TODO: Turn into optionally typed identifiers

type EditableBody* = ref object of Editable
    lines*: seq[Editable]

type EditableProcedureDefinition* = ref object of Editable
    name*: EditableUnparsed ## TODO: Turn into an editable identifier
    parameters*: EditableParameters
    body*: EditableBody

type EditableSetStatement* = ref object of Editable
    variable*: EditableUnparsed ## TODO: Turn into an editable identifier
    value*: Editable

### Font Info
type FontInfo* = ref object
    texture*: TexturePtr
    glyph_size*: cint
    glyph_x_stride*: cint
    glyph_y_stride*: cint
