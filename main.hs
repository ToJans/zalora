{-# LANGUAGE OverloadedStrings #-}

module Main where

import Web.Scotty
import Network.Wai.Middleware.RequestLogger(logStdoutDev)
import Data.Aeson ( (.:),(.:?),decode,FromJSON(..),Value(..))
import Data.Text.Lazy (pack)
import Control.Applicative ((<$>), (<*>))
import qualified Data.ByteString.Lazy.Char8 as BS

data Shoes = Shoes
  { id          :: Maybe String
  , description :: String
  , color       :: String
  , size        :: String
  , photo       :: String
  } deriving Show

instance FromJSON Shoes where
  parseJSON (Object v) = Shoes
    <$> (v .:? "id")
    <*> (v .: "description")
    <*> (v .: "color")
    <*> (v .: "size")
    <*> (v .: "photo")


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
  b <- body
  let (Just shoes) = decode b :: Maybe Shoes
  let shoesName = "shoes_1"
  persistShoes $ shoesName shoes
  redirect $ "/" + shoesName + ".html"
  where
    persistShoes name shoes = do
      let shoesString = show $ shoes
      persist $ name "json" shoesString
      persist $ name "jpg" shoes.photo
      persist $ name "html" shoesHtml $ name shoes
    shoesHtml name shoes = "<p>" + shoes.description + "</p><img href='"+name+"'.jpg />"
    persist name ext content = writeFile $ (name + "." + ext) content



