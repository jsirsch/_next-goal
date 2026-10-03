module UI.Event (handleEvent) where

import RIO
import State
import Types
import Brick
import qualified Brick.Widgets.Edit as E
import qualified Graphics.Vty as V
import Lens.Micro ((^.), (.~), (%~))

handleEvent :: BrickEvent () e -> EventM () AppState ()
handleEvent (VtyEvent e) = do
  st <- get
  if st ^. asIsCreating
    then handleCreationEvent e
    else handleGlobalEvent e
handleEvent _ = pure ()

handleCreationEvent :: V.Event -> EventM () AppState ()
handleCreationEvent (V.EvKey V.KEsc []) =
  modify $ (asIsCreating .~ False) . (asGoalInput %~ E.applyEdit (const [])) -- clear input
handleCreationEvent (V.EvKey V.KEnter []) = do
  -- TODO: Save goal to state and disk
  modify $ (asIsCreating .~ False) . (asGoalInput %~ E.applyEdit (const []))
handleCreationEvent e = do
  zoom asGoalInput $ E.handleEditorEvent (VtyEvent e)

handleGlobalEvent :: V.Event -> EventM () AppState ()
handleGlobalEvent (V.EvKey (V.KChar 'q') []) = halt
handleGlobalEvent (V.EvKey (V.KChar 'n') []) = modify (asIsCreating .~ True)
handleGlobalEvent (V.EvKey (V.KChar '1') []) = modify (asCurrentPage .~ PageNextGoal)
handleGlobalEvent (V.EvKey (V.KChar '2') []) = modify (asCurrentPage .~ PageBacklog)
handleGlobalEvent (V.EvKey (V.KChar '3') []) = modify (asCurrentPage .~ PageKanban)
handleGlobalEvent (V.EvKey (V.KChar '4') []) = modify (asCurrentPage .~ PageHierarchy)
handleGlobalEvent (V.EvKey (V.KChar 'h') []) = modify (asCurrentPage .~ PageHelp)
handleGlobalEvent _ = pure ()
