## Local imports
import ../globals
import ../types

## Library imports

## Standard imports
{. warning[UnusedImport]:off .}
import sugar
import std/tables
import std/strutils
import std/options
import std/strformat
import system/dollars

### Editable Code
method `$`*(x: Editable): string {.base.} = discard
method textyIterator*(x: Editable, texties: var seq[Texty]) {.base.} = discard
method maybeFirst*(x: Editable): Option[Editable] {.base.} = discard
method maybeLast*(x: Editable): Option[Editable] {.base.} = discard
method maybeNextEditableOfChild*(x: Editable, child: Editable): Option[Editable] {.base.} = discard
method maybePreviousEditableOfChild*(x: Editable, child: Editable): Option[Editable] {.base.} = discard
method replaceChild*(x: Editable, child: Editable, new_child: Editable) {.base.} = assert false
proc maybeNextEditableLeaveSoUnparsedRightNow*(x: Editable): Option[Editable] =
    var current = x
    while true:
        ## Check for children
        let maybe_child = current.maybeFirst
        if maybe_child.isSome:
            if maybe_child.get() of EditableUnparsed:
                return maybe_child
            current = maybe_child.get()
            continue

        ## Otherwise go to first sibling of a forefather
        while true:
            if current.parent.isNil:
                return

            let maybe_sibling = current.parent.maybeNextEditableOfChild(current)
            if maybe_sibling.isSome:
                if maybe_sibling.get() of EditableUnparsed:
                    return maybe_sibling
                current = maybe_sibling.get()
                break
            current = current.parent
proc replaceWith*(x: Editable, new_x: Editable) = x.parent.replaceChild(x, new_x)

proc maybePreviousEditableLeaveSoUnparsedRightNow*(x: Editable): Option[Editable] =
    var current = x
    while true:
        ## Check for children
        let maybe_child = current.maybeLast
        if maybe_child.isSome:
            if maybe_child.get() of EditableUnparsed:
                return maybe_child
            current = maybe_child.get()
            continue

        ## Otherwise go to first sibling of a forefather
        while true:
            if current.parent.isNil:
                return

            let maybe_sibling = current.parent.maybePreviousEditableOfChild(current)
            if maybe_sibling.isSome:
                if maybe_sibling.get() of EditableUnparsed:
                    return maybe_sibling
                current = maybe_sibling.get()
                break
            current = current.parent


## Literal
method `$`*(x: EditableLiteral): string =
    fmt"literal<{x.value}>"

method textyIterator*(x: EditableLiteral, texties: var seq[Texty]) =
    texties.add(Texty(text: "glob::", kind: Punctuation))
    texties.add(Texty(text: x.value, kind: Literal))

method maybeFirst*(x: EditableLiteral): Option[Editable] =
    none[Editable]()

method maybeLast*(x: EditableLiteral): Option[Editable] =
    none[Editable]()

method maybeNextEditableOfChild*(x: EditableLiteral, child: Editable): Option[Editable] = discard
method maybePreviousEditableOfChild*(x: EditableLiteral, child: Editable): Option[Editable] = discard
method replaceChild*(x: EditableLiteral, child: Editable, new_child: Editable) = assert false

proc initEditableLiteral*(value: string): EditableLiteral =
    result = EditableLiteral(value: value)


## Unparsed
method `$`*(x: EditableUnparsed): string =
    fmt"unparsed<{x.value}>"

method textyIterator*(x: EditableUnparsed, texties: var seq[Texty]) =
    if G.optionally_selected_editable.isSome and G.optionally_selected_editable.get() == x:
        texties.add(Texty(text: x.value, kind: CurrentlyTyping, currently_typing_kind: Unparsed))
    else:
        texties.add(Texty(text: x.value, kind: Unparsed))

method maybeFirst*(x: EditableUnparsed): Option[Editable] =
    none[Editable]()

method maybeLast*(x: EditableUnparsed): Option[Editable] =
    none[Editable]()

method maybeNextEditableOfChild*(x: EditableUnparsed, child: Editable): Option[Editable] = discard
method maybePreviousEditableOfChild*(x: EditableUnparsed, child: Editable): Option[Editable] = discard
method replaceChild*(x: EditableUnparsed, child: Editable, new_child: Editable) = assert false

proc initEditableUnparsed*(value: string): EditableUnparsed =
    result = EditableUnparsed(value: value)


## Expression with suffix writing
method `$`*(x: EditableExpressionWithSuffixWriting): string =
    fmt"expression_with_suffix_writing<{x.expression}, {x.suffix_unparsed}>"

method textyIterator*(x: EditableExpressionWithSuffixWriting, texties: var seq[Texty]) =
    x.expression.textyIterator(texties)
    x.suffix_unparsed.textyIterator(texties)

method maybeFirst*(x: EditableExpressionWithSuffixWriting): Option[Editable] =
    some(x.expression)

method maybeLast*(x: EditableExpressionWithSuffixWriting): Option[Editable] =
    some(cast[Editable](x.suffix_unparsed))

method maybeNextEditableOfChild*(x: EditableExpressionWithSuffixWriting, child: Editable): Option[Editable] = assert false: "not implemented"
method maybePreviousEditableOfChild*(x: EditableExpressionWithSuffixWriting, child: Editable): Option[Editable] = assert false: "not implemented"
method replaceChild*(x: EditableExpressionWithSuffixWriting, child: Editable, new_child: Editable) =
    if child == x.expression:
        x.expression = new_child
    else:
        assert child == x.suffix_unparsed
        assert new_child of EditableUnparsed
        x.suffix_unparsed = cast[EditableUnparsed](new_child)

proc initEditableExpressionWithSuffixWriting*(expression: Editable, suffix_unparsed: EditableUnparsed): EditableExpressionWithSuffixWriting =
    result = EditableExpressionWithSuffixWriting(expression: expression, suffix_unparsed: suffix_unparsed)
    suffix_unparsed.parent = result
    expression.parent = result


## Comment
method `$`*(x: EditableComment): string =
    fmt"comment<{x.unparsed}>"

method textyIterator*(x: EditableComment, texties: var seq[Texty]) =
    texties.add(Texty(text: "##", kind: Literal))
    
    if G.optionally_selected_editable == some(cast[Editable](x.unparsed)):
        texties.add(Texty(text: x.unparsed.value, kind: CurrentlyTyping, currently_typing_kind: Literal))
    else:
        texties.add(Texty(text: x.unparsed.value, kind: Literal))

method maybeFirst*(x: EditableComment): Option[Editable] =
    some(cast[Editable](x.unparsed))

method maybeLast*(x: EditableComment): Option[Editable] =
    some(cast[Editable](x.unparsed))

method maybeNextEditableOfChild*(x: EditableComment, child: Editable): Option[Editable] = discard
method maybePreviousEditableOfChild*(x: EditableComment, child: Editable): Option[Editable] = discard
method replaceChild*(x: EditableComment, child: Editable, new_child: Editable) = assert false

proc initEditableComment*(unparsed: EditableUnparsed): EditableComment =
    result = EditableComment(unparsed: unparsed)
    unparsed.parent = result


## Parameters
method `$`*(x: EditableParameters): string =
    let s = x.parameters_unparsed.join(", ")
    fmt"params<{s}>"

method textyIterator*(x: EditableParameters, texties: var seq[Texty]) =
    texties.add(Texty(text: "(", kind: Punctuation))
    var is_first = true
    for value in x.parameters_unparsed:
        if not is_first:
            texties.add(Texty(text: ", ", kind: Punctuation))
        textyIterator(value, texties)
        is_first = false
    texties.add(Texty(text: ")", kind: Punctuation))
    
method maybeFirst*(x: EditableParameters): Option[Editable] =
    if x.parameters_unparsed.len > 0:
        result = some(cast[Editable](x.parameters_unparsed[0]))
    
method maybeLast*(x: EditableParameters): Option[Editable] =
    if x.parameters_unparsed.len > 0:
        result = some(cast[Editable](x.parameters_unparsed[^1]))

method maybeNextEditableOfChild*(x: EditableParameters, child: Editable): Option[Editable] =
    let index = x.parameters_unparsed.find(cast[EditableUnparsed](child)) + 1
    if index < x.parameters_unparsed.len:
        result = some(cast[Editable](x.parameters_unparsed[index]))

method maybePreviousEditableOfChild*(x: EditableParameters, child: Editable): Option[Editable] =
    let index = x.parameters_unparsed.find(cast[EditableUnparsed](child)) - 1
    if index >= 0:
        result = some(cast[Editable](x.parameters_unparsed[index]))

method replaceChild*(x: EditableParameters, child: Editable, new_child: Editable) =
    assert false

proc initEditableParameters*(parameters_unparsed: seq[EditableUnparsed]): EditableParameters =
    result = EditableParameters(parameters_unparsed: parameters_unparsed)
    for value in parameters_unparsed:
        value.parent = result


## Body
method `$`*(x: EditableBody): string =
    let s = x.lines.join(" \\n ")
    fmt"body<{s}>"

method textyIterator*(x: EditableBody, texties: var seq[Texty]) =
    texties.add(Texty(text: "\t\n", kind: Spacing))
    for value in x.lines:
        textyIterator(value, texties)
        texties.add(Texty(text: "\n", kind: Spacing))
    texties.add(Texty(text: "\r", kind: Spacing))

method maybeFirst*(x: EditableBody): Option[Editable] =
    if x.lines.len > 0:
        result = some(cast[Editable](x.lines[0]))

method maybeLast*(x: EditableBody): Option[Editable] =
    if x.lines.len > 0:
        result = some(cast[Editable](x.lines[^1]))

method maybeNextEditableOfChild*(x: EditableBody, child: Editable): Option[Editable] =
    let index = x.lines.find(child) + 1
    if index < x.lines.len:
        result = some(x.lines[index])

method maybePreviousEditableOfChild*(x: EditableBody, child: Editable): Option[Editable] =
    let index = x.lines.find(child) - 1
    if index >= 0:
        result = some(x.lines[index])

method replaceChild*(x: EditableBody, child: Editable, new_child: Editable) =
    let index = x.lines.find(child)
    x.lines[index] = new_child
    new_child.parent = x

proc initEditableBody*(lines: seq[Editable]): EditableBody =
    result = EditableBody(lines: lines)
    for value in lines:
        value.parent = result


## Procedure Definition
method `$`*(x: EditableProcedureDefinition): string =
    fmt"proc<{x.name} {x.parameters} {x.body}>"

method textyIterator*(x: EditableProcedureDefinition, texties: var seq[Texty]) =
    texties.add(Texty(text: "proc", kind: Keyword))
    texties.add(Texty(text: " ", kind: Spacing))
    textyIterator(x.name, texties)
    textyIterator(x.parameters, texties)
    texties.add(Texty(text: " ", kind: Spacing))
    texties.add(Texty(text: "=", kind: Punctuation))
    textyIterator(x.body, texties)
    
method maybeFirst*(x: EditableProcedureDefinition): Option[Editable] =
    some(cast[Editable](x.name))
    
method maybeLast*(x: EditableProcedureDefinition): Option[Editable] =
    some(cast[Editable](x.body))
    
method maybeNextEditableOfChild*(x: EditableProcedureDefinition, child: Editable): Option[Editable] =
    if child of EditableUnparsed:
        result = some(cast[Editable](x.parameters))
    elif child of EditableParameters:
        result = some(cast[Editable](x.body))
    
method maybePreviousEditableOfChild*(x: EditableProcedureDefinition, child: Editable): Option[Editable] =
    if child of EditableParameters:
        result = some(cast[Editable](x.name))
    elif child of EditableBody:
        result = some(cast[Editable](x.parameters))

method replaceChild*(x: EditableProcedureDefinition, child: Editable, new_child: Editable) =
    if child == x.name: x.name = cast[EditableUnparsed](new_child)
    elif child == x.parameters: x.parameters = cast[EditableParameters](new_child)
    else: x.body = cast[EditableBody](new_child)
    new_child.parent = x

proc initEditableProcedureDefinition*(name: EditableUnparsed, parameters: EditableParameters, body: EditableBody): EditableProcedureDefinition =
    result = EditableProcedureDefinition(name: name, parameters: parameters, body: body)
    name.parent = result
    parameters.parent = result
    body.parent = result

## Set statement
method `$`*(x: EditableSetStatement): string =
    fmt"set<{x.variable} {x.value}>"

method textyIterator*(x: EditableSetStatement, texties: var seq[Texty]) =
    texties.add(Texty(text: "set", kind: Keyword))
    texties.add(Texty(text: " ", kind: Spacing))
    textyIterator(x.variable, texties)
    texties.add(Texty(text: " ", kind: Spacing))
    texties.add(Texty(text: "=", kind: Punctuation))
    texties.add(Texty(text: " ", kind: Spacing))
    textyIterator(x.value, texties)
    
method maybeFirst*(x: EditableSetStatement): Option[Editable] =
    some(cast[Editable](x.variable))
    
method maybeLast*(x: EditableSetStatement): Option[Editable] =
    some(cast[Editable](x.value))

method maybeNextEditableOfChild*(x: EditableSetStatement, child: Editable): Option[Editable] =
    if child == x.variable:
        result = some(x.value)

method maybePreviousEditableOfChild*(x: EditableSetStatement, child: Editable): Option[Editable] =
    if child == x.value:
        result = some(cast[Editable](x.variable))

method replaceChild*(x: EditableSetStatement, child: Editable, new_child: Editable) =
    assert false

proc initEditableSetStatement*(variable: EditableUnparsed, value: Editable): EditableSetStatement =
    result = EditableSetStatement(variable: variable, value: value)
    variable.parent = result
    value.parent = result


# ## Editables via templates
# type CodeNode* = ref object of RootObj
#     parent: Option[CodeNode]



