## Local imports
import globals
import sdl_wrapper
import types
import colors

## Library imports
import sdl2
import std/strformat
import std/strutils

### Drawing
proc drawScreen*() =
    ## Background
    G.renderer.setDrawColor 8, 21, 27, 255 # dark cyan
    G.renderer.clear()

    ## Texties
    var
        x_left: cint = 0
        x: cint = 0
        y: cint = 0
    for texty in G.texties:
        ## Spacing/layout
        if texty.kind == Spacing:
            for c in texty.text:
                case c
                of ' ':
                    x += 10
                of '\t':
                    x_left += 40
                    x = x_left
                of '\r':
                    x_left -= 40
                    x = x_left
                of '\n':
                    y += 16
                    x = x_left
                else:
                    raiseAssert(fmt"Invalid spacing character '{c}'")
            continue
        ## Colored Text
        let color =
            case texty.kind
            of Todo:
                color(130, 255, 160, 255)
            of Keyword:
                color(255, 130, 160, 255)
            else:
                color(255, 255, 255, 255)
        drawStandardSizeTextFast(cstring(texty.text), color, x, y)
        x += 10 * cast[cint](texty.text.len)

    ## Bottom bar
    G.renderer.setDrawColor(140, 140, 240, 255) # Light magenta
    var below_bar_rect = rect(
        0,
        G.height - 30,
        G.width,
        30)
    G.renderer.fillRect(below_bar_rect)
    drawStandardSizeTextFast(cstring(fmt"FPS: {G.current_fps:>5.1f}"), color(255, 255, 255, 255), (30 - 16) div 2, G.height - 16 - (30 - 16) div 2)
    drawStandardSizeTextFast(cstring($G.focus_mode), color(255, 255, 255, 255), G.width - ((30 - 16) div 2) - 10 * cast[cint](len($G.focus_mode)), G.height - 16 - (30 - 16) div 2)
    
    ## Optional search bar
    if G.focus_mode == FocusMode.Search:
        G.renderer.setDrawColor(28, 41, 47, 255) # Lighter cyan than background
        var search_bar_rect = rect(
            G.width div 2,
            0,
            G.width - (G.width div 2),
            30)
        G.renderer.fillRect(search_bar_rect)
        drawText(16, cstring(fmt"Search: '{G.current_search_term}'"), color(255, 255, 255, 255), G.width div 2 + ((30 - 16) div 2), (30 - 16) div 2)

    ## Optional creation window
    if G.focus_mode == FocusMode.CreationWindow:
        ## Completion options ## TODO: implement actual filtering + have actual data to filter ;)
        var filtered_options: seq[Texty] = @[]
        if startswith("def", G.creation_window_search) or startswith("proc", G.creation_window_search) or startswith("func", G.creation_window_search):
            filtered_options.add(Texty(text: "proc", kind: Keyword))
        if startswith("if", G.creation_window_search):
            filtered_options.add(Texty(text: "if then", kind: Keyword))
        if startswith("#", G.creation_window_search):
            filtered_options.add(Texty(text: "comment", kind: Todo))
        if filtered_options.len == 0:
            filtered_options.add(Texty(text: fmt"create '{G.creation_window_search}'", kind: Literal))
        filtered_options.add(Texty(text: "second to last", kind: Todo))
        filtered_options.add(Texty(text: "the last", kind: Todo))
        let selected_index = 0

        ## Drawing Container
        G.renderer.setDrawColor(28, 41, 47, 255) # Lighter cyan than background
        let
            creation_window_width: cint = 300
            creation_window_height: cint = cast[cint](filtered_options.len) * 20 + 30
        var creation_window_rect = padded(rect(
            (G.width - creation_window_width) div 2,
            (G.height - creation_window_height) div 2,
            creation_window_width,
            creation_window_height), 5)
        fillPaddedRoundedRect(creation_window_rect)

        ## Query text
        let max_query_text_width = (creation_window_width div 10)
        let text = if G.creation_window_search.len < max_query_text_width: G.creation_window_search else: G.creation_window_search[^max_query_text_width .. ^1]
        var y: cint = (G.height - creation_window_height) div 2
        
        let query_text_rect = rect(
            (G.width - creation_window_width) div 2,
            (G.height - creation_window_height) div 2,
            creation_window_width,
            20)
        G.renderer.setDrawColor(17, 119, 187, 255)
        fillPaddedRoundedRect(padded(query_text_rect, 2))
        G.renderer.setDrawColor(68, 81, 87, 255)
        fillPaddedRoundedRect(padded(query_text_rect, 1))

        drawStandardSizeTextFast(cstring(text), color(200, 200, 200, 255), (G.width - creation_window_width) div 2, y)
        let cursor_x = (G.width - creation_window_width) div 2 + cast[cint](text.len) * 10
        G.renderer.setDrawColor(200, 200, 200, 255)
        G.renderer.drawLine(cursor_x, (G.height - creation_window_height) div 2, cursor_x, (G.height - creation_window_height) div 2 + 20)
        y += 30

        ## Options text
        for option in filtered_options:
            ## Check if selected
            let selected = option == filtered_options[selected_index]

            ## Color selection
            let color =
                if selected:
                    case option.kind
                    of Todo:
                        color(130, 255, 160, 255)
                    of Keyword:
                        color(255, 170, 180, 255)
                    else:
                        whitestWhite
                else:
                    case option.kind
                    of Todo:
                        color(110, 235, 140, 255)
                    of Keyword:
                        color(235, 110, 140, 255)
                    else:
                        color(230, 230, 230, 255)

            ## Optional selected background
            if selected:
                G.renderer.setDrawColor(17, 119, 187, 255)
                fillPaddedRoundedRect(rect((G.width - creation_window_width) div 2, y + 1, creation_window_width, 18))
            
            ## Option text
            let max_option_text_width = (creation_window_width div 10) - 5
            let text = if option.text.len < max_option_text_width: option.text else: option.text[^max_option_text_width .. ^1]
            drawStandardSizeTextFast(cstring(text), color, (G.width - creation_window_width) div 2, y)

            ## Little tildes for ~~aethestics~~
            let length = max(10 - cast[cint](len(text)), 4)
            drawStandardSizeTextFast(cstring("~".repeat(length)), color(128, 128, 128, 255), ((G.width + creation_window_width) div 2) - 10 * length, y)           
            
            ## Advance the line position
            y += 20

    ## Show the result
    G.renderer.present()
