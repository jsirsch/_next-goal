module UI.Event (handleEvent) where

import RIO
import State
import Store
import Types
import Brick
import qualified Brick.Widgets.Edit as E
import qualified Graphics.Vty as V
import qualified Data.Text as T
import Lens.Micro ((^.), (.~), (%~))

handleEvent :: BrickEvent () e -> EventM () AppState ()
handleEvent (VtyEvent e) = do
  st <- get
  if st ^. asIsCreating
    then handleCreationEvent e
    else do
      if st ^. asCurrentPage == PageBacklog
        then handleBacklogEvent e
        else handleGlobalEvent e
handleEvent _ = pure ()

handleCreationEvent :: V.Event -> EventM () AppState ()
handleCreationEvent (V.EvKey V.KEsc []) =
  modify $ (asIsCreating .~ False) . (asGoalInput .~ E.editor () (Just 1) "") -- clear input
handleCreationEvent (V.EvKey V.KEnter []) = do
  st <- get
  let textLines = E.getEditContents (st ^. asGoalInput)
      title = T.unlines textLines
  unless (T.null (T.strip title)) $ do
    let nextId = if RIO.null (st ^. asGoals) then 1 else foldr (\g acc -> max (goalId g) acc) 0 (st ^. asGoals) + 1
        newGoal = Goal nextId title StatusTodo Nothing Nothing
        newGoals = (st ^. asGoals) ++ [newGoal]
    
    -- Save to disk
    liftIO $ runRIO (st ^. asEnv) $ saveGoals newGoals
    
    modify $ asGoals .~ newGoals
  
  modify $ (asIsCreating .~ False) . (asGoalInput .~ E.editor () (Just 1) "")
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

handleBacklogEvent :: V.Event -> EventM () AppState ()
handleBacklogEvent e = do
  st <- get
  let goalsLen = length (st ^. asGoals)
      idx = st ^. asSelectedGoalIndex
      
      swapAdjacent i lst =
        let (before, rest) = splitAt i lst
        in case rest of
             (x:y:after) -> before ++ (y:x:after)
             _           -> lst -- Fallback if out of bounds

  case e of
    -- Move cursor down
    V.EvKey (V.KChar 'j') [] | idx < goalsLen - 1 -> modify $ asSelectedGoalIndex .~ (idx + 1)
    V.EvKey V.KDown []       | idx < goalsLen - 1 -> modify $ asSelectedGoalIndex .~ (idx + 1)
    
    -- Move cursor up
    V.EvKey (V.KChar 'k') [] | idx > 0 -> modify $ asSelectedGoalIndex .~ (idx - 1)
    V.EvKey V.KUp []         | idx > 0 -> modify $ asSelectedGoalIndex .~ (idx - 1)
    
    -- Swap down
    V.EvKey (V.KChar 'J') [] | idx < goalsLen - 1 -> do
      let newGoals = swapAdjacent idx (st ^. asGoals)
      liftIO $ runRIO (st ^. asEnv) $ saveGoals newGoals
      modify $ (asGoals .~ newGoals) . (asSelectedGoalIndex .~ (idx + 1))
    V.EvKey V.KDown [V.MShift] | idx < goalsLen - 1 -> do
      let newGoals = swapAdjacent idx (st ^. asGoals)
      liftIO $ runRIO (st ^. asEnv) $ saveGoals newGoals
      modify $ (asGoals .~ newGoals) . (asSelectedGoalIndex .~ (idx + 1))
      
    -- Swap up
    V.EvKey (V.KChar 'K') [] | idx > 0 -> do
      let newGoals = swapAdjacent (idx - 1) (st ^. asGoals)
      liftIO $ runRIO (st ^. asEnv) $ saveGoals newGoals
      modify $ (asGoals .~ newGoals) . (asSelectedGoalIndex .~ (idx - 1))
    V.EvKey V.KUp [V.MShift] | idx > 0 -> do
      let newGoals = swapAdjacent (idx - 1) (st ^. asGoals)
      liftIO $ runRIO (st ^. asEnv) $ saveGoals newGoals
      modify $ (asGoals .~ newGoals) . (asSelectedGoalIndex .~ (idx - 1))
      
    -- Fallback to global events
    _ -> handleGlobalEvent e
