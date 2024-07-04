module Main where

import Data.Function

main :: IO ()
main = do
  [3..999]
  & filter (\x -> mult3 x || mult5 x)
  & sum
  & print;

mult3 :: Integer -> Bool
mult3 x = mod x 3 == 0

mult5 :: Integer -> Bool
mult5 x = mod x 5 == 0
