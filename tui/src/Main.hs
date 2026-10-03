module Main where

import RIO
import Types
import State
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
  logOptions <- logOptionsHandle stderr False
  withLogFunc logOptions $ \lf -> do
    let env = AppEnv { appLogFunc = lf, appDataDir = "." }
    runRIO env $ do
      initialVty <- liftIO $ VCP.mkVty V.defaultConfig
      _finalState <- liftIO $ customMain initialVty (VCP.mkVty V.defaultConfig) Nothing app initialState
      -- We can save state to disk here later
      pure ()
