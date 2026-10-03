module Types where

import RIO
import RIO.Time (UTCTime)
import Data.Aeson (FromJSON, ToJSON)

-- | Represents the different views in the application
data Page
  = PageNextGoal
  | PageBacklog
  | PageKanban
  | PageHierarchy
  deriving (Show, Eq)

-- | Status for Kanban
data GoalStatus
  = StatusTodo
  | StatusInProgress
  | StatusDone
  deriving (Show, Eq, Generic, FromJSON, ToJSON)

-- | Core Goal domain model
data Goal = Goal
  { goalId       :: Int
  , goalTitle    :: Text
  , goalStatus   :: GoalStatus
  , goalDeadline :: Maybe UTCTime -- If set, represents calendar schedule
  , goalParentId :: Maybe Int     -- For hierarchy
  } deriving (Show, Eq, Generic, FromJSON, ToJSON)

-- | Global RIO Environment
data AppEnv = AppEnv
  { appLogFunc :: LogFunc
  , appDataDir :: FilePath
  }

instance HasLogFunc AppEnv where
  logFuncL = lens appLogFunc (\x y -> x { appLogFunc = y })
