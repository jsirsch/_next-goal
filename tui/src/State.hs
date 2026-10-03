module State where

import RIO
import Types
import Lens.Micro.TH (makeLenses)
import qualified Brick.Widgets.Edit as E
import Data.Aeson (FromJSON, ToJSON)

-- | The application's UI and data state
data AppState = AppState
  { _asGoals       :: [Goal]
  , _asCurrentPage :: Page
  , _asIsCreating  :: Bool
  , _asGoalInput   :: E.Editor Text ()
  }

makeLenses ''AppState

-- | Initial empty state
initialState :: AppState
initialState = AppState
  { _asGoals       = []
  , _asCurrentPage = PageNextGoal
  , _asIsCreating  = False
  , _asGoalInput   = E.editor () (Just 1) ""
  }
