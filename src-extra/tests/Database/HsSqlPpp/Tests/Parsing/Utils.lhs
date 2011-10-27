
> module Database.HsSqlPpp.Tests.Parsing.Utils where

> import Database.HsSqlPpp.Ast
> import Database.HsSqlPpp.Annotation

> data Item = Expr String ScalarExpr
>           | Stmt String [Statement]
>           | MSStmt String [Statement]
>           | PgSqlStmt String [Statement]
>           | Group String [Item]

-------------------------------------------------------------------------------

shortcuts for constructing test data and asts

> stringQ :: String -> ScalarExpr
> stringQ = StringLit ea
>
> selectFrom :: SelectItemList
>            -> TableRef
>            -> QueryExpr
> selectFrom selList frm = Select ea Dupes (SelectList ea selList)
>                            [frm] Nothing [] Nothing [] Nothing Nothing
>
> selectE :: SelectList -> QueryExpr
> selectE selList = Select ea Dupes selList
>                     [] Nothing [] Nothing [] Nothing Nothing
>
> selIL :: [String] -> [SelectItem]
> selIL = map selI
> selEL :: [ScalarExpr] -> [SelectItem]
> selEL = map (SelExp ea)
>
> i :: String -> Name
> i x = Name ea [Nmc x]

> dqi :: String -> Name
> dqi x = Name ea [Nmc x]

> eqi :: String -> String -> ScalarExpr
> eqi c = QIdentifier ea (Identifier ea c)

> ei :: String -> ScalarExpr
> ei = Identifier ea
>
> qi :: String -> String -> Name
> qi c n = Name ea [Nmc c, Nmc n]
>
> selI :: String -> SelectItem
> selI = SelExp ea . Identifier ea
>
> sl :: SelectItemList -> SelectList
> sl = SelectList ea
>
> selectFromWhere :: SelectItemList
>                 -> TableRef
>                 -> ScalarExpr
>                 -> QueryExpr
> selectFromWhere selList frm whr =
>     Select ea Dupes (SelectList ea selList)
>                [frm] (Just whr) [] Nothing [] Nothing Nothing
>
> att :: String -> String -> AttributeDef
> att n t = AttributeDef ea (Nmc n) (SimpleTypeName ea t) Nothing []

> ea :: Annotation
> ea = emptyAnnotation