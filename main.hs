{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}

module Main where

import GHC.Generics
import Web.Scotty
import Network.Wai.Middleware.RequestLogger
import Data.Aeson.Types

data Shoes = Shoes
  { id          :: Maybe String
  , description :: String
  , color       :: String
  , size        :: String
  , photo       :: String
  } deriving Generic

instance FromJSON Shoes

main = scotty 3000 $ do
  middleware logStdoutDev
  get "/"       showIndex
  get "/:shoes" showShoes
  post "/"      postShoes

showIndex = do
  file "index.html"

showShoes = do
  shoes <- param "shoes"
  file $ shoes ++ ".html"


postShoes = do
  shoesData <- jsonData
  html $ shoesData

  -- I somehow need to convert JSON in a html file and rebuild index.html
  -- afterwards redirect to "/:shoes"
  -- let shoesName = "new_shoes"
  -- redirect "/" ++ shoesName ++ ".html"
