module UI.Draw (drawUI) where

import RIO
import State
import Types
import Brick
import qualified Brick.Widgets.Border as B
import qualified Brick.Widgets.Center as C
import qualified Brick.Widgets.Edit as E
import qualified Data.Text as T
import Lens.Micro ((^.))

drawUI :: AppState -> [Widget ()]
drawUI st =
  let pageWidget = case st ^. asCurrentPage of
        PageNextGoal  -> drawNextGoal st
        PageBacklog   -> drawBacklog st
        PageKanban    -> drawKanban st
        PageHierarchy -> drawHierarchy st
        PageHelp      -> drawHelp st
      
      mainView = vBox [ pageWidget
                      , drawFooter st
                      ]

      -- Modal overlay if creating a goal
      layers = if st ^. asIsCreating
               then [drawCreationModal st, mainView]
               else [mainView]
  in layers

drawNextGoal :: AppState -> Widget ()
drawNextGoal st = C.center $ B.borderWithLabel (str " Next Goal ") $ padAll 2 $
  case listToMaybe (st ^. asGoals) of
    Nothing -> str "No goals found. Press 'n' to create one."
    Just g  -> vBox [ str "Target: " <+> txt (goalTitle g)
                    , str "Status: " <+> str (show (goalStatus g))
                    ]

drawBacklog :: AppState -> Widget ()
drawBacklog st = C.center $ B.borderWithLabel (str " Prioritized Backlog ") $ padAll 2 $
  if RIO.null (st ^. asGoals)
    then str "Backlog is empty."
    else vBox $ map (\g -> str ("- ") <+> txt (goalTitle g)) (st ^. asGoals)

drawKanban :: AppState -> Widget ()
drawKanban _st = C.center $ str "Kanban Board (WIP)"

drawHierarchy :: AppState -> Widget ()
drawHierarchy _st = C.center $ str "Goal Hierarchy (WIP)"

drawCreationModal :: AppState -> Widget ()
drawCreationModal st =
  C.centerLayer $
  B.borderWithLabel (str " Create New Goal ") $
  padAll 1 $
  vBox [ str "Title: " <+> E.renderEditor (txt . T.unlines) True (st ^. asGoalInput)
       , str "Press Enter to save, Esc to cancel."
       ]


drawHelp :: AppState -> Widget ()
drawHelp _st = C.center $ B.borderWithLabel (str " Help ") $ padAll 2 $
  vBox [ str "Global Shortcuts:"
       , str "  1 : Next Goal"
       , str "  2 : Prioritized Backlog"
       , str "  3 : Kanban Board"
       , str "  4 : Goal Hierarchy"
       , str "  h : This Help Page"
       , str "  n : Create New Goal"
       , str "  q : Quit"
       ]

drawFooter :: AppState -> Widget ()
drawFooter st =
  let p = st ^. asCurrentPage
      stylePage curr target label = if curr == target then "[" <> label <> "]" else " " <> label <> " "
  in padTop (Pad 1) $ C.hCenter $ str $
       stylePage p PageNextGoal "1:NextGoal" <> " | " <>
       stylePage p PageBacklog "2:Backlog" <> " | " <>
       stylePage p PageKanban "3:Kanban" <> " | " <>
       stylePage p PageHierarchy "4:Hierarchy" <> " | " <>
       stylePage p PageHelp "h:Help"
