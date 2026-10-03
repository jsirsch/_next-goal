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
  , _asEnv         :: AppEnv
  }

makeLenses ''AppState

-- | Initial state with injected env and loaded goals
initialState :: AppEnv -> [Goal] -> AppState
initialState env goals = AppState
  { _asGoals       = goals
  , _asCurrentPage = PageNextGoal
  , _asIsCreating  = False
  , _asGoalInput   = E.editor () (Just 1) ""
  , _asEnv         = env
  }
