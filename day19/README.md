# Haskell yet again

This problem is either again unsolvable in nix or I just don't know about the secret memoization tactic used by nix professionals. Even though I googled for a pretty long time while trying to solve day 11... To keep the pure FP spirit yet again solved it with Haskell. Again using the mighty [memoize](https://hackage.haskell.org/package/memoize) package.

## Part 1

```hs
module Main where

import Data.Function.Memoize (memoFix)
import Data.List (isPrefixOf)

makeSolve :: [String] -> (String -> Bool)
makeSolve patterns =
  let solve :: (String -> Bool) -> String -> Bool
      solve _ "" = True
      solve f str = any (\p -> p `isPrefixOf` str && f (drop (length p) str)) patterns
   in memoFix solve

main :: IO ()
main = do
  raw <- readFile "input"

  let input = lines raw
      patterns = map (filter (/= ',')) $ words $ head input
      targets = drop 2 input

      solve = makeSolve patterns
      answer = length $ filter solve targets

  print answer
```

## Part 2

```hs
module Main where

import Data.Function.Memoize (memoFix)
import Data.List (isPrefixOf)

makeSolve :: [String] -> (String -> Integer)
makeSolve patterns =
  let solve :: (String -> Integer) -> String -> Integer
      solve _ "" = 1
      solve f str =
        let count p =
              if p `isPrefixOf` str
                then f (drop (length p) str)
                else 0
            counts = map count patterns
         in sum counts
   in memoFix solve

main :: IO ()
main = do
  raw <- readFile "input"

  let input = lines raw
      patterns = map (filter (/= ',')) $ words $ head input
      targets = drop 2 input

      solve = makeSolve patterns
      answer = sum $ map solve targets

  print answer
```
