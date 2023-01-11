## Local imports

## Library imports
import sdl2
import math

## Standard imports
{. warning[UnusedImport]:off .}
import sugar
import std/tables
import std/strutils
import std/options
import std/strformat
import system/dollars

### Color convertion functions
func hlsHelper(m1 : float, m2 : float, hue : float): float =
    var hue2 : float = hue mod 1.0
    if hue2 < (1.0 / 6.0):
        return m1 + ((m2 - m1) * hue2 * 6.0)
    if hue2 < 0.5:
        return m2
    if hue2 < (2.0 / 3.0):
        return m1 + ((m2 - m1) * ((2.0 / 3.0) - hue2) * 6.0)
    return m1

func hlsToRgbFloat(h, l, s: float): seq[float] =
    if s == 0.0:
        return @[l, l, l]
    var m1 : float
    var m2 : float
    if l <= 0.5:
        m2 = l * (1.0 + s)
    else:
        m2 = l + s - (l * s)
    m1 = (2.0 * l) - m2
    return @[hlsHelper(m1, m2, (h + (1.0 / 3.0))), hlsHelper(m1, m2, h), hlsHelper(m1, m2, (h - (1.0 / 3.0)))]

func hlsToRgb*(h, l, s: float): Color {. compiletime .} =
    let rgb = hlsToRgbFloat(h, l, s)
    return color(max(0, (rgb[0] * 255).round.toInt), max(0, (rgb[1] * 255).round.toInt), max(0, (rgb[2] * 255).round.toInt), 255)

const whitestWhite* = color(255, 255, 255, 255)
const greyedOutWhite* = color(212, 212, 212, 255)
const brightYellow* = color(255, 215, 0, 255)
const brightPurple* = color(218, 112, 214, 255)
const dimYellow* = color(220, 220, 170, 255)
const cactusGreen* = color(106, 153, 85, 255)
const cursorGrey* = color(174, 175, 173, 255)
const niceBlue* = color(86, 156, 214, 255)
