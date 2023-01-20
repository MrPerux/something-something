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

{.experimental: "codeReordering".}

### AST
## Base types
type Ast* = ref object of RootObj
    parent: Ast

type AstStatementOrDeclaration* = ref object of Ast
    nil

type AstStatement* = ref object of AstStatementOrDeclaration
    nil

type AstExpression* = ref object of AstStatement
    nil

## Identifiers
type IdentID* = string
type IdentDecl* = ref object of Ast
    nil
type IdentDeclProcedure = IdentDecl
type IdentDeclParameter = IdentDecl
type IdentDeclLocalVariable = IdentDecl

## Procedure
type AstProcedure* = ref object of AstStatementOrDeclaration
    procedure_identifier: IdentDeclProcedure
    parameters: AstParameters

## Parameters
type AstParameter* = ref object of Ast
    name: IdentDeclParameter
type AstParameters* = seq[AstParameter]

## Statements
type AstBody* = ref object of AstStatement
    statements: seq[AstStatementOrDeclaration]

type AstModify* = ref object of AstStatement
    lvalue: AstLValue
    rvalue: AstExpression

type AstFor* = ref object of AstStatement
    introducing: AstLValue
    iterator_expression: AstExpression
    body: AstBody

## Expressions
type AstLValue* = ref object of AstExpression
    nil ## TODO: fields

type AstCaseSwitch* = ref object of AstExpression
    value_to_check: AstExpression
    cases: seq[AstCaseSingular]

type AstCaseSingular* = (AstExpression, AstBody) ## TODO: make union of AstExpression, default/else case

type AstIdentUse* = ref object of AstExpression
    name: IdentID

type AstProcedureCall* = ref object of AstExpression
    procedure: AstExpression
    arguments: AstArguments

type AstArguments* = seq[AstArgument]
type AstArgument* = (IdentID, AstExpression) ## TODO: How will we keep resolved identifiers if named arguments AND higher order functions are a thing?
