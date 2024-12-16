# Regarding part 2

Solved the second part with zig initially. I'm pretty sure, it might be impossible with pure nix, since it doesn't have any efficient way of memoizing function return values (even though all of them are pure) like Haskell does (using mutability under the hood). With immutable cache it just runs out of memory.

By the way, here's the Haskell solution to keep the pure FP spirit:

```hs
module Main where

import Data.Function.Memoize (memoFix2)

split :: Integer -> Maybe (Integer, Integer)
split num =
  let len = length (show num)
      power = 10 ^ (len `div` 2)
      left = num `div` power
      right = num `mod` power
   in if even len then Just (left, right) else Nothing

blink :: (Integer -> Integer -> Integer) -> Integer -> Integer -> Integer
blink _ 0 _ = 1
blink f times 0 = f (times - 1) 1
blink f times n = case split n of
  Just (left, right) -> f (times - 1) left + f (times - 1) right
  Nothing -> f (times - 1) (n * 2024)

blink' :: Integer -> Integer -> Integer
blink' = memoFix2 blink

solve :: [Integer] -> Integer
solve = sum . map (blink' 75)

main :: IO ()
main = do
  input <- readFile "input"
  let arr = map read $ words input
  print $ solve arr
```
