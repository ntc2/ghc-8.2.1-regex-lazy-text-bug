{-# LANGUAGE FlexibleContexts #-}
module Main where

-- Problem only happens using Data.Text.Lazy, and only *without*
-- profiling. Heisenbug!

import           Control.Monad ( when )
import qualified Data.Text as TS
import qualified Data.Text.IO as TS
import qualified Data.Text.Lazy as TL
import qualified Data.Text.Lazy.IO as TL
import qualified System.Environment as SE
import           System.Exit ( die )
import           Text.Printf ( printf )
import qualified Text.RE.TDFA as RE

main :: IO ()
main = do
  args <- SE.getArgs
  when (length args /= 2) usage
  let [mode, file] = args
  case mode of
    "string"      -> test readFile    lines    file
    "text-strict" -> test TS.readFile TS.lines file
    "text-lazy"   -> test TL.readFile TL.lines file
    _             -> usage

test ::
  (RE.IsRegex RE.RE text) =>
  (String -> IO text) -> (text -> [text]) -> String -> IO ()
test readFile lines file = do
  printf "File: %s\n" file
  t <- readFile file
  printf "Lines: %i\n" (length $ lines t)
  re <- RE.compileRegex "^def "
  let defCount = RE.countMatches (t RE.*=~ re)
  printf "Defs: %i\n" defCount

usage :: IO ()
usage = do
  progName <- SE.getProgName
  die $ printf "usage: %s (string | text-strict | text-lazy) FILE" progName
