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
