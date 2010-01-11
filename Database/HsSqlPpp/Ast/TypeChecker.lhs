Copyright 2009 Jake Wheat

This is the public module for the type checking functionality.

> {- | Contains the data types and functions for annotating
>  an ast and working with annotated trees, including the
>  representations of SQL data types.
>
> Annotations:
>
> * are attached to most of the ast node data types, but not quite all of them;
>
> * types annotations are attached to most nodes during type checking;
>
> * type errors are attached to the lowest down node that the type error is detected at;
>
> * nodes who fail the type check or whose type depends on a node with a type error are
>   given the type 'TypeCheckFailed';
>
> * each statement has an additional 'StatementInfo' annotation attached to it;
>
> * the parser fills in the source position annotation in every annotatable ast node.
>
> -}
> module Database.HsSqlPpp.Ast.TypeChecker
>     (
>      -- * typechecking/ annotation functions
>       typeCheck
>      ,typeCheckMany
>      ,typeCheckExpression
>      -- * Annotated tree utils
>     ,getTopLevelTypes
>     ,getTopLevelInfos
>     ,getTopLevelEnvUpdates
>     ,getTypeErrors
>     ,getStatementAnnotations
>     ) where

> import Database.HsSqlPpp.AstInternals.AstInternal
> import Database.HsSqlPpp.AstInternals.AstAnnotation
> import Database.HsSqlPpp.AstInternals.AnnotationUtils
