-----------------------------------------------------------------------------
-- |
-- Module      :  TestSuite.Queries.Int_Boolector
-- Copyright   :  (c) Levent Erkok
-- License     :  BSD3
-- Maintainer  :  erkokl@gmail.com
-- Stability   :  experimental
--
-- Testing Boolector specific interactive features.
-----------------------------------------------------------------------------
{-# LANGUAGE ScopedTypeVariables #-}

module TestSuite.Queries.Int_Boolector (tests)  where

import Data.SBV
import Data.SBV.Control

import SBVTest

-- Test suite
tests :: TestTree
tests =
  testGroup "Basics.QueryIndividual"
    [ goldenCapturedIO "query_boolector" $ print =<< runSMTWith boolector{verbose=True} q
    ]

q :: Symbolic (Int32, Int32)
q = do a <- sInt32 "a"
       b <- sInt32 "b"

       constrain $ a .> 0
       constrain $ b .> 0

       query $ do constrain $ a+2 .<= 15
                  constrain $ a   .<  3
                  constrain $ b   .<  2
                  constrain $ a+b .< 12

                  constrain $ a .< 2
                  cs <- checkSat

                  case cs of
                    Sat -> io $ putStrLn "Everything is OK"
                    Unk -> io .print =<< getInfo ReasonUnknown
                    r   -> error $ "Something went bad, why not-sat/unk?: " ++ show r

                  -- Query a/b
                  av <- getValue a
                  bv <- getValue b
                  io $ putStrLn $ "(a,b) = " ++ show (av, bv)

                  -- Now assert so that we get even a bigger value..
                  constrain $ a .>= 1
                  _ <- checkSat

                  (,) <$> getValue a <*> getValue b