Copyright 2010 Jake Wheat

Small hack transform and load the chaos sql into the database.

ghc -XDeriveDataTypeable -isrc:devel:tests:examples/extensions:examples/dbload:examples/chaos -hide-package monads-fd --make examples/chaos/Chaos2010.lhs && time examples/chaos/Chaos2010 sql > chaos1.sql && time examples/chaos/Chaos2010 clear && time psql chaos -q --set ON_ERROR_STOP=on --file=chaos1.sql


> import System.Environment
> import System.Console.CmdArgs
> import System.IO
> import Control.Monad.Error

> --import Debug.Trace
> import Data.Maybe
> import Data.Generics.Uniplate.Data
>
> --import Database.HsSqlPpp.Tests.Tests
> import Database.HsSqlPpp.Utils.Utils
>
> import Database.HsSqlPpp.Catalog
> import qualified Database.HsSqlPpp.TypeChecker as A
> import Database.HsSqlPpp.Annotation
> import Database.HsSqlPpp.SqlTypes
>
> import qualified Database.HsSqlPpp.Parser as P
>
> import Database.HsSqlPpp.PrettyPrinter
>
> import Database.HsSqlPpp.Utils.DatabaseLoader
> --import Database.HsSqlPpp.WrapperGen
> import Database.HsSqlPpp.Utils.DBUtils
>
> import Database.HsSqlPpp.Chaos.ChaosExtensions
> import Database.HsSqlPpp.Chaos.ChaosFiles

 > import Database.HsSqlPpp.Examples.Chaos2010



> main :: IO()
> main = do
>   argv <- getArgs
>   case argv of
>     ["reset"] -> reset
>     ["sql"] -> sql
>     ["check"] -> check
>     ["clear"] -> clearDB "chaos"
>     x -> putStrLn $ "don't understand " ++ show x

-------------------------------------------------------------------------------

> reset :: IO ()
> reset = wrapETs $ do
>   let db = "chaos"
>   --clear the db and get the transformed ast
>   liftIO $ do
>     hSetBuffering stdout NoBuffering
>     clearDB db
>   ast <- mapM (\f -> (liftIO . readInput) f >>=
>                  tsl . P.parseSql f) chaosFiles >>=
>      return . (concat |>
>                chaosExtensions)
>   liftIO $ loadAst db ast
>   return ()


> sql :: IO ()
> sql = wrapETs $ do
>   ast <- mapM (\f -> (liftIO . readInput) f >>=
>                  tsl . P.parseSql f) chaosFiles >>=
>      return . (concat |>
>                chaosExtensions)
>   liftIO $ putStrLn $ printSql ast
>   return ()

> check :: IO ()
> check = wrapETs $ do
>   --clear the db and get the transformed ast
>   ast <- mapM (\f -> (liftIO . readInput) f >>=
>                  tsl . P.parseSql f) chaosFiles >>=
>      return . (concat |>
>                chaosExtensions)
>   mapM_ (liftIO . putStrLn) $
>             (A.typeCheck defaultTemplate1Catalog |>
>              snd |>
>              getTypeErrors |>
>              ppTypeErrors) ast
>   return ()



> -- | read a file as text, will read from stdin if filename is '-'.
> readInput :: FilePath -> IO String
> readInput f =
>   case f of
>              "-" -> getContents
>              _ | length f >= 2 &&
>                  head f == '"' && last f == '"'
>                    -> return $ drop 1 $ take (length f - 1) f
>                | otherwise -> readFile f

> -- | Pretty print list of type errors with optional source position
> --   in emacs readable format.
> ppTypeErrors :: [(Maybe (String,Int,Int), [TypeError])] -> [String]
> ppTypeErrors tes =
>   map showSpTe tes
>   where
>     showSpTe (Just (fn,l,c), e) =
>         fn ++ ":" ++ show l ++ ":" ++ show c ++ ":\n" ++ show e
>     showSpTe (_,e) = "unknown:0:0:\n" ++ show e

> getTypeErrors :: Data a => a -> [(Maybe (String,Int,Int), [TypeError])]
> getTypeErrors es =
>   let as = [(a::Annotation) | a <- universeBi es]
>   in mapMaybe getTes as
>   where
>     getTes as = let tes = errs as
>                 in if null tes
>                    then Nothing
>                    else Just (asrc as, tes)
