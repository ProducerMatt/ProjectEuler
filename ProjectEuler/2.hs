module Main where

import Data.Function

main :: IO ()
main = do
  [3..999]
  & filter (\x -> mult3 x || mult5 x)
  & sum
  & print;

fibRec :: Integer -> Integer
fibRec 0 = 0
fibRec 1 = 1
fibRec x = (fibRec (x - 1)) + (fibRec (x - 2))

fibIter :: Integer -> Integer -> (Integer, Integer)
fibIter x y = (y, x + y)

fib :: [Integer]
fib =
  let start = (0, 1)
    in 

