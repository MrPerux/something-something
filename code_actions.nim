## Local imports
import globals
import types
import editables

## Library imports
import sugar
import std/tables
import std/options
import std/algorithm
import system/dollars

{.experimental: "codeReordering".}

### Code actions for adding code
proc addTodoProcedureAndSwitch*() =
    var procedure = initEditableProcedureDefinition(
        initEditableUnparsed("proc2"),
        initEditableParameters(@[initEditableUnparsed("param1"), initEditableUnparsed("param2")]),
        initEditableBody(@[cast[Editable](initEditableUnparsed("whoop whoop")), cast[Editable](initEditableUnparsed("TODO"))]))
    G.all_editables.add(procedure)
    G.current_slice.lines.add(procedure) ## TODO: should we update filter?
    
    procedure.parent = G.current_slice
    changeOptionallySelectedEditable(some(cast[Editable](procedure.body.lines[^1])))

proc addUnparsedInTopLevel*() =
    var unparsed = initEditableUnparsed("I'm here")
    G.all_editables.add(unparsed)
    G.current_slice.lines.add(unparsed) ## TODO: should we update filter?
    unparsed.parent = G.current_slice


proc addTopLevelSmallProcedureWithName*(name: string) =
    var procedure = initEditableProcedureDefinition(
        initEditableUnparsed(name),
        initEditableParameters(@[initEditableUnparsed("johan")]),
        initEditableBody(@[cast[Editable](initEditableUnparsed("..."))]))
    G.all_editables.add(procedure)
    G.current_slice.lines.add(procedure) ## TODO: should we update filter?
    procedure.parent = G.current_slice

proc addIfStatementAndSwitch*() =
    discard ## TODO
proc addCommentAndSwitch*() =
    discard ## TODO

proc changeOptionallySelectedEditable*(x: Option[Editable]) =
    G.optionally_selected_editable = x
    updateWritingContext()

## Removing code
proc maybeDeleteCurrentLineInParentBody*() =
    if G.optionally_selected_editable.isSome and not G.optionally_selected_editable.get().parent.isNil and G.optionally_selected_editable.get().parent of EditableBody:
        let to_remove = G.optionally_selected_editable.get()
        var body = cast[EditableBody](to_remove.parent)
        if body.lines.len > 1:
            let index = body.lines.find(to_remove)
            changeOptionallySelectedEditable(to_remove.maybePreviousEditableLeaveSoUnparsedRightNow)
            body.lines.delete(index)

## Writing Stuff
proc getWritingContext*(unparsed: Editable): WritingContext =
    var grandparents: seq[Editable] = @[]
    
    let is_top_level = unparsed.parent == G.current_slice
    if is_top_level:
        result.keywords["proc"] = (Proc, "Procedure")
        result.keywords["def"] = (Proc, "Procedure")
        result.operators["##"] = (Comment, "Comment")
        result.allow_newline_make_new_unparsed_in_ancestor_body = true
    
    let can_be_start_of_statement = not is_top_level and unparsed.parent of EditableBody
    if can_be_start_of_statement:
        result.keywords["if"] = (If, "If <cond> then")
        result.keywords["set"] = (Set, "Set <var> = <value>")
        result.operators["##"] = (Comment, "Comment")
        result.allow_newline_make_new_unparsed_in_ancestor_body = true

    if unparsed.parent of EditableComment:
        result.allow_newline_make_new_unparsed_in_ancestor_body = true


    var x = unparsed
    while not x.parent.isNil:
        x = x.parent
        grandparents.add(x)
    grandparents.reverse
    # for granny in grandparents:
    #     if 

proc updateWritingContext*() =
    G.optional_writing_context = none[WritingContext]()
    if G.optionally_selected_editable.isSome:
        assert G.optionally_selected_editable.get() of EditableUnparsed
        G.optional_writing_context = some(getWritingContext(G.optionally_selected_editable.get()))

proc handleKeywordOption*(option: KeywordOption) =
    let (name, keyword, description) = option
    
    let presumably_unparsed = G.optionally_selected_editable.get()
    assert presumably_unparsed of EditableUnparsed
    case keyword
    of Proc:
        let new_proc = initEditableProcedureDefinition(
            initEditableUnparsed("TODO"),
            initEditableParameters(@[]),
            initEditableBody(@[cast[Editable](initEditableUnparsed("..."))]))
        replaceWith(
            presumably_unparsed, new_proc)
        changeOptionallySelectedEditable(some(cast[Editable](new_proc.name)))
    of If:
        let new_editable = initEditableUnparsed("If yehaw!")
        replaceWith(presumably_unparsed, new_editable)
        changeOptionallySelectedEditable(some(cast[Editable](new_editable)))
    of Comment:
        let new_editable = initEditableComment(initEditableUnparsed(""))
        if presumably_unparsed.parent of EditableExpressionWithSuffixWriting:
            let presumably_body = presumably_unparsed.parent.parent
            assert presumably_body of EditableBody
            var body = cast[EditableBody](presumably_body)
            body.lines.insert(cast[Editable](new_editable), body.lines.find(presumably_unparsed.parent))
            new_editable.parent = body
            replaceWith(presumably_unparsed.parent, cast[EditableExpressionWithSuffixWriting](presumably_unparsed.parent).expression)
        
        else:
            replaceWith(presumably_unparsed, new_editable)
        # echo "Doing code action comment"
        # echo "The tree before: " & $G.current_slice
        changeOptionallySelectedEditable(some(cast[Editable](new_editable.unparsed)))
        # echo "The tree after: " & $G.current_slice
    of Set:
        let new_editable = initEditableUnparsed("TODO")
        replaceWith(presumably_unparsed, new_editable)
        changeOptionallySelectedEditable(some(cast[Editable](new_editable)))
    of FillerSoThingWontBeEmpty:
        discard

proc handleNewline*() =
    var child = G.optionally_selected_editable.get()
    while true:
        echo "Current child: " & $child
        echo "Its parent: " & $child.parent
        let parent = child.parent
        if parent of EditableBody:
            var body = cast[EditableBody](parent)
            let child_index = body.lines.find(child)
            var new_editable = initEditableUnparsed("")
            new_editable.parent = body
            body.lines.insert(new_editable, child_index + 1)
            changeOptionallySelectedEditable(some(cast[Editable](new_editable)))
            return
        assert not parent.isNil
        child = parent
