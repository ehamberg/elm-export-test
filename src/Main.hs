{-# LANGUAGE DataKinds              #-}
{-# LANGUAGE DeriveGeneric          #-}
{-# LANGUAGE FlexibleInstances      #-}
{-# LANGUAGE FunctionalDependencies #-}
{-# LANGUAGE RankNTypes             #-}
{-# LANGUAGE ScopedTypeVariables    #-}
{-# LANGUAGE TemplateHaskell        #-}
{-# LANGUAGE TypeApplications       #-}

module Main where

import Data.Aeson
import Data.Map (Map, fromList)
import Elm (ElmType, Spec (..), toElmDecoderSource, toElmTypeSource)
import GHC.Generics
import Network.Wai.Handler.Warp
import Servant
import Servant.Elm
import Network.Wai.Middleware.Cors

data Foo = Foo { foo :: Map String Int }
  deriving (Generic)

instance ToJSON Foo
instance ElmType Foo

type API = Get '[JSON] Foo

startApp :: IO ()
startApp = run 8080 app

app :: Application
app = simpleCors $ serve api server

api :: Proxy API
api = Proxy

server :: Server API
server = return (Foo (fromList [("1", 1), ("2", 2)]))

apiSpec :: Spec
apiSpec = Spec ["Api"]
  ( defElmImports
  : "import Dict exposing (Dict)\n\n"
  : toElmTypeSource (Proxy :: Proxy Foo)
  : toElmDecoderSource (Proxy :: Proxy Foo)
  : generateElmForAPIWith options (Proxy :: Proxy API)
  )
  where options = defElmOptions { urlPrefix = Dynamic }

main :: IO ()
main = do
  specsToDir [apiSpec] "."
  startApp
