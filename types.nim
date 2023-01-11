## Local imports

## Library imports
import sdl2
import sugar
import std/tables
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


### Focus
type FocusMode* = enum
    Text
    Search
    CreationWindow
    GotoWindow


## Filter
type FilterKind* = enum
    FilterOnName
    FilterOnType
    FilterOnNumberOfLinesInFunctionBody

type FilterTypeKind* = enum
    FunctionDefition
    TypeDefinition

type Filter* = object
    case kind*: FilterKind
    of FilterOnName:
        name_to_filter*: string
    of FilterOnType:
        type_to_filter*: FilterTypeKind
    of FilterOnNumberOfLinesInFunctionBody:
        at_least_n_lines*: int

### Editable Code
type Editable* = ref object of RootObj
    parent*: Editable

type EditableLiteral* = ref object of Editable
    value*: string

type EditableUnparsed* = ref object of Editable
    value*: string

type EditableExpressionWithSuffixWriting* = ref object of Editable
    expression*: Editable
    suffix_unparsed*: EditableUnparsed

type EditableComment* = ref object of Editable
    unparsed*: EditableUnparsed
    
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


### Writing Context
type WritingKeyword* = enum
    Proc
    If
    Comment
    Set
    FillerSoThingWontBeEmpty

type WritingContext* = object
    # keywords*: Table[string, (string, string)]
    keywords*: Table[string, (WritingKeyword, string)]
    operators*: Table[string, (WritingKeyword, string)]
    allow_newline_make_new_unparsed_in_ancestor_body*: bool

type KeywordOption* = (string, WritingKeyword, string)

### Font Info
type FontInfo* = ref object
    texture*: TexturePtr
    glyph_size*: cint
    glyph_baseline_y*: cint
    glyph_x_stride*: cint
    glyph_y_stride*: cint
    glyph_atlas_width*: cint
    glyph_atlas_height*: cint


### Text Alignment
type TextAlignment* = enum
    Left
    Center
    Right
const Top* = Left
const Bottom* = Right
