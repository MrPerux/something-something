## Local imports

## Library imports
import sdl2

## Standard imports
{. warning[UnusedImport]:off .}
import sugar
import std/tables
import std/strutils
import std/options
import std/strformat
import system/dollars

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


### Focus
type FocusMode* = enum
    Text
    Search


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
