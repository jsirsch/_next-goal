module Store where

import RIO
import Types
import Data.Aeson (encode, decodeStrict)
import qualified RIO.ByteString as B
import System.Directory (doesFileExist)
import System.FilePath ((</>))

getGoalsFile :: RIO AppEnv FilePath
getGoalsFile = do
  env <- ask
  pure $ appDataDir env </> "goals.json"

loadGoals :: RIO AppEnv [Goal]
loadGoals = do
  fp <- getGoalsFile
  exists <- liftIO $ doesFileExist fp
  if exists
    then do
      content <- B.readFile fp
      case decodeStrict content of
        Just goals -> do
          logInfo $ "Loaded " <> displayShow (length goals) <> " goals."
          pure goals
        Nothing -> do
          logError "Failed to parse goals.json, starting with empty goals."
          pure []
    else do
      logInfo "No goals.json found, starting fresh."
      pure []

saveGoals :: [Goal] -> RIO AppEnv ()
saveGoals goals = do
  fp <- getGoalsFile
  B.writeFile fp (RIO.toStrictBytes $ encode goals)
  logInfo "Saved goals to disk."
