## Local imports
import globals
import sdl_wrapper
import types
import colors
import autocomplete
import editables
import text_rendering
import drawing_helper

## Library imports
import sdl2
import std/strformat
import std/strutils

### Draw everything
proc drawScreen*() =
    ## Background
    G.renderer.setDrawColor 8, 21, 27, 255 ## Dark cyan
    G.renderer.clear()

    ## Texties
    let texties_font = G.standard_font
    var
        x_left: cint = if G.show_texty_line_names: 160 else: 0
        x: cint = 0
        y: cint = 40
    for idx, named_texty_line in G.texty_lines:
        if G.show_texty_line_names:
            let name_string = fmt"{named_texty_line.name.substr(max(0, named_texty_line.name.len - 15)):<15} "
            drawTextFast(G.standard_font, name_string, whitestWhite, 0, y)
            x += cast[cint](name_string.len) * texties_font.glyph_x_stride
        var texties: seq[Texty]
        named_texty_line.editable.textyIterator(texties)
        for texty in texties:
            ## Spacing/layout
            if texty.kind == Spacing:
                for c in texty.text:
                    case c
                    of ' ':
                        x += texties_font.glyph_x_stride
                    of '\t':
                        x_left += texties_font.glyph_x_stride * 4
                        x = x_left
                    of '\r':
                        x_left -= texties_font.glyph_x_stride * 4
                        x = x_left
                    of '\n':
                        y += texties_font.glyph_y_stride
                        x = x_left
                    else:
                        raiseAssert(fmt"Invalid spacing character '{c}'")
                continue
            ## Colored Text
            let kind_to_color = if texty.kind == CurrentlyTyping: texty.currently_typing_kind else: texty.kind
            let color =
                case kind_to_color
                of Todo:
                    color(120, 120, 120, 255)
                of Unparsed:
                    color(235, 180, 210, 255)
                of Keyword:
                    color(255, 130, 160, 255)
                else:
                    whitestWhite
                    
            drawTextFast(G.standard_font, texty.text, color, x, y)
            x += texties_font.glyph_x_stride * cast[cint](texty.text.len)
            if texty.kind == CurrentlyTyping:
                drawCursor(texties_font, x, y)
                # sdlAssertSuccess G.renderer.drawLine(x, y, x, y + texties_font.glyph_size)
                # sdlAssertSuccess G.renderer.drawLine(x - 1, y, x - 1, y + texties_font.glyph_size)

                ## These next two lines are needed to fix a stray pixel introduced by the previous drawLine
                ## Namely, after the drawLine the next call to renderer.copy in drawStandardSizeTextFast
                ## produces a stray pixel in the bottom right corner of the character drawn. This
                ## is most likely a driver issue and might not be reproducable on other systems.
                G.renderer.setDrawColor 8, 21, 27, 255 ## Dark cyan (background)
                sdlAssertSuccess G.renderer.drawLine(0, 0, 0, 0)
            
        ## New line
        y += texties_font.glyph_y_stride
        xleft = if G.show_texty_line_names: 160 else: 0
        x = 0

    ## Bottom bar
    G.renderer.setDrawColor(140, 140, 240, 255) ## Light magenta
    var below_bar_rect = rect(
        0,
        G.height - 30,
        G.width,
        30)
    G.renderer.fillRect(below_bar_rect)
    # drawTextFast(G.standard_font, fmt"FPS: {G.current_fps:>5.1f}", whitestWhite, (30 - 16) div 2, G.height - 16 - (30 - 16) div 2)
    drawTextFastAlign(G.standard_font, fmt"FPS: {G.current_fps:>5.1f}", whitestWhite, (30 - G.standard_font.glyph_size) div 2, G.height - 30 div 2, Left, Center)
    drawTextFastAlign(G.standard_font, $G.focus_mode, whitestWhite, G.width - ((30 - G.standard_font.glyph_size) div 2), G.height - 30 div 2, Right, Center)
    
    ## Optional search bar
    if G.focus_mode == FocusMode.Search:
        G.renderer.setDrawColor(28, 41, 47, 255) ## Lighter cyan than background
        var search_bar_rect = rect(
            G.width div 2,
            0,
            G.width - (G.width div 2),
            30)
        G.renderer.fillRect(search_bar_rect)
        drawText(16, fmt"Search: '{G.current_search_term}'", whitestWhite, G.width div 2 + ((30 - 16) div 2), (30 - 16) div 2)

    ## Optional creation window
    if G.focus_mode == FocusMode.CreationWindow:
        remakeCreationWindowSelectionOptions()

        ## Drawing Container
        G.renderer.setDrawColor(28, 41, 47, 255) ## Lighter cyan than background
        let
            creation_window_width: cint = 300
            creation_window_height: cint = cast[cint](G.creation_window_selection_options.len) * 20 + 30
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

        drawTextFast(G.standard_font, text, color(200, 200, 200, 255), (G.width - creation_window_width) div 2, y)
        let cursor_x = (G.width - creation_window_width) div 2 + cast[cint](text.len) * 10
        G.renderer.setDrawColor(200, 200, 200, 255)
        G.renderer.drawLine(cursor_x, (G.height - creation_window_height) div 2, cursor_x, (G.height - creation_window_height) div 2 + 20)
        y += 30

        ## Options text
        for option in G.creation_window_selection_options:
            ## Check if selected
            let selected = option == G.creation_window_selection_options[G.creation_window_selection_index]

            ## Color selection
            let color =
                if selected:
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
            drawTextFast(G.standard_font, text, color, (G.width - creation_window_width) div 2, y)

            ## Little tildes for ~~aethestics~~
            if selected:
                let length = max(10 - cast[cint](len(text)), 4)
                drawTextFast(G.standard_font, "~".repeat(length), color(178, 178, 178, 255), ((G.width + creation_window_width) div 2) - 10 * length, y)           
            
            ## Advance the line position
            y += 20

    
    ## Optional goto window
    if G.focus_mode == FocusMode.GotoWindow:
        remakeGotoWindowSelectionOptions()

        ## Drawing Container
        G.renderer.setDrawColor(28, 41, 47, 255) ## Lighter cyan than background
        let
            goto_window_width: cint = 300
            goto_window_height: cint = cast[cint](G.goto_window_selection_options.len) * 20 + 30
        var goto_window_rect = padded(rect(
            (G.width - goto_window_width) div 2,
            (G.height - goto_window_height) div 2,
            goto_window_width,
            goto_window_height), 5)
        fillPaddedRoundedRect(goto_window_rect)

        ## Query text
        let max_query_text_width = (goto_window_width div 10)
        let text = if G.goto_window_search.len < max_query_text_width: G.goto_window_search else: G.goto_window_search[^max_query_text_width .. ^1]
        var y: cint = (G.height - goto_window_height) div 2
        
        let query_text_rect = rect(
            (G.width - goto_window_width) div 2,
            (G.height - goto_window_height) div 2,
            goto_window_width,
            20)
        G.renderer.setDrawColor(17, 119, 187, 255)
        fillPaddedRoundedRect(padded(query_text_rect, 2))
        G.renderer.setDrawColor(68, 81, 87, 255)
        fillPaddedRoundedRect(padded(query_text_rect, 1))

        drawTextFast(G.standard_font, text, color(200, 200, 200, 255), (G.width - goto_window_width) div 2, y)
        let cursor_x = (G.width - goto_window_width) div 2 + cast[cint](text.len) * 10
        G.renderer.setDrawColor(200, 200, 200, 255)
        G.renderer.drawLine(cursor_x, (G.height - goto_window_height) div 2, cursor_x, (G.height - goto_window_height) div 2 + 20)
        y += 30

        ## Options text
        for option in G.goto_window_selection_options:
            ## Check if selected
            let selected = option == G.goto_window_selection_options[G.goto_window_selection_index]

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
                fillPaddedRoundedRect(rect((G.width - goto_window_width) div 2, y + 1, goto_window_width, 18))
            
            ## Option text
            let max_option_text_width = (goto_window_width div 10) - 5
            let text = if option.text.len < max_option_text_width: option.text else: option.text[^max_option_text_width .. ^1]
            drawTextFast(G.standard_font, text, color, (G.width - goto_window_width) div 2, y)

            ## Little tildes for ~~aethestics~~
            let length = max(10 - cast[cint](len(text)), 4)
            drawTextFast(G.standard_font, "~".repeat(length), color(128, 128, 128, 255), ((G.width + goto_window_width) div 2) - 10 * length, y)           
            
            ## Advance the line position
            y += 20

    ## Show the result
    G.renderer.present()
