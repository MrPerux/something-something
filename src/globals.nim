## Local imports
import types

## Library imports
import os
import sdl2
import sdl2/ttf

## Standard imports
{. warning[UnusedImport]:off .}
import sugar
import std/tables
import std/strutils
import std/options
import std/strformat
import system/dollars

{.experimental: "codeReordering".}

type Globals* = object
    ## Window properties
    running*: bool
    width*: cint
    height*: cint
    window*: WindowPtr
    window_title*: cstring
    renderer*: RendererPtr
    current_fps*: float
    was_typing_apostrophe_like_character*: char
    debug_mode*: bool
    
    ## Is screen maximized
    is_screen_maximized*: bool

    ## Current focus
    focus_stack*: seq[FocusMode]

    ## Search bar
    current_search_term*: string

    ## Fonts
    switchable_fonts*: seq[FontInfo]
    standard_font*: FontInfo
    fonts*: Table[cint, FontPtr]


var G* = Globals(
    running: true,
    is_screen_maximized: fileExists("runtime/maximized_mode.option"),
    focus_stack: @[FocusMode.Text],
    current_search_term: "poodles",
)


func focus_mode*(g: Globals): FocusMode =
    g.focus_stack[^1]
