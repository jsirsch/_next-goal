module UI.Draw (drawUI) where

import RIO
import State
import Types
import Brick
import qualified Brick.Widgets.Border as B
import qualified Brick.Widgets.Center as C
import qualified Brick.Widgets.Edit as E
import Lens.Micro ((^.))

drawUI :: AppState -> [Widget ()]
drawUI st =
  let pageWidget = case st ^. asCurrentPage of
        PageNextGoal  -> drawNextGoal st
        PageBacklog   -> drawBacklog st
        PageKanban    -> drawKanban st
        PageHierarchy -> drawHierarchy st
      
      -- Modal overlay if creating a goal
      layers = if st ^. asIsCreating
               then [drawCreationModal st, pageWidget]
               else [pageWidget]
  in layers

drawNextGoal :: AppState -> Widget ()
drawNextGoal _st = C.center $ B.borderWithLabel (str " Next Goal ") $ padAll 2 (str "No goal prioritized yet.")

drawBacklog :: AppState -> Widget ()
drawBacklog _st = C.center $ str "Prioritized Backlog (WIP)"

drawKanban :: AppState -> Widget ()
drawKanban _st = C.center $ str "Kanban Board (WIP)"

drawHierarchy :: AppState -> Widget ()
drawHierarchy _st = C.center $ str "Goal Hierarchy (WIP)"

drawCreationModal :: AppState -> Widget ()
drawCreationModal st =
  C.centerLayer $
  B.borderWithLabel (str " Create New Goal ") $
  padAll 1 $
  vBox [ str "Title: " <+> E.renderEditor (str . RIO.unlines) True (st ^. asGoalInput)
       , str "Press Enter to save, Esc to cancel."
       ]
