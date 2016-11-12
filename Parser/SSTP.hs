module Parser.SSTP
  ( Command (..)
  , SecurityLevel (..)
  , Request (..)
  , parseSSTPRequest) where

import Data.List (sort)
import Text.Parsec hiding (newline)
import Text.Parsec.String


data Command = GetVersion
             | Execute
             deriving (Show, Read, Eq)

data SecurityLevel = Local
                   | External
                   deriving (Show, Read, Eq)

data Request = Request Command (Maybe SecurityLevel) [String]
             deriving (Show, Read, Eq)

parseSSTPRequest :: String -> Either ParseError Request
parseSSTPRequest = parse parseRequest "SSTP Request"

parseRequest :: Parser Request
parseRequest = do
  c <- parseCommand
  newline
  skipMany $ try (string "Sender:" >> many (noneOf "\r\n") >> newline) <|>
             (string "Charset:" >> many (noneOf "\r\n") >> newline)
  s <- optionMaybe parseSecurityLevel
  newline
  as <- many parseArgument
  let as' = map snd . sort $ as
  return $ Request c s as'

newline :: Parser ()
newline = string "\r\n">> return ()

parseCommand :: Parser Command
parseCommand = do
  c <- parseGetVersion <|>
       parseExecute
  _ <- space
  _ <- string "SAORI/1.0"
  return c
  where
    parseGetVersion = string "GET Version" >> return GetVersion
    parseExecute = string "EXECUTE" >> return Execute

parseSecurityLevel :: Parser SecurityLevel
parseSecurityLevel = do
  _ <- string "SecurityLevel:"
  spaces
  parseLocal <|> parseExternal
  where
    parseLocal = string "Local" >> return Local
    parseExternal = string "External" >> return External

parseArgument :: Parser (Int, String)
parseArgument = do
  _ <- string "Argument"
  d <- many1 digit
  char ':' >> spaces
  s <- many (noneOf "\r\n")
  _ <- many newline
  return (read d, s)
