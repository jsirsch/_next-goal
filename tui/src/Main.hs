module Main where

import RIO
import Types
import State
import Store
import UI.Draw
import UI.Event
import Brick
import qualified Graphics.Vty as V
import qualified Graphics.Vty.CrossPlatform as VCP

app :: App AppState e ()
app = App
  { appDraw = drawUI
  , appChooseCursor = showFirstCursor
  , appHandleEvent = handleEvent
  , appStartEvent = pure ()
  , appAttrMap = const $ attrMap V.defAttr []
  }

main :: IO ()
main = do
  RIO.withFile "next-goal.log" RIO.AppendMode $ \logHandle -> do
    logOptions <- logOptionsHandle logHandle False
    withLogFunc logOptions $ \lf -> do
      let env = AppEnv { appLogFunc = lf, appDataDir = "." }
      runRIO env $ do
        goals <- loadGoals
        initialVty <- liftIO $ VCP.mkVty V.defaultConfig
        let st = initialState env goals
        _finalState <- liftIO $ customMain initialVty (VCP.mkVty V.defaultConfig) Nothing app st
        pure ()
