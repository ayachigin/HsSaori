module Saori where

import Parser.SSTP

request:: String -> String
request s = message
  where
    as = case parseSSTPRequest s of
                                 (Right (Request _ _ xs)) -> xs
                                 (Left _) -> [s]
    l = if null as then "引数がありません" else  head as
    message = "SAORI/1.0 200 OK\r\n" ++
              "Charset: UTF-8\r\n" ++
              "Result: " ++ l ++ "\r\n\r\n"
