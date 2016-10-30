{-# LANGUAGE ForeignFunctionInterface #-}
module HsSaori where

import Foreign.C.String
import Foreign.C.Types (CLong)
import Foreign.Marshal.Alloc
import Foreign.Ptr (nullPtr, Ptr, castPtr)
import System.Win32.Mem

foreign export ccall load :: HGLOBAL -> Ptr CLong -> IO Bool
foreign export ccall unload :: IO Bool
foreign export ccall request :: HGLOBAL -> Ptr CLong -> IO HGLOBAL

request :: HGLOBAL -> Ptr CLong -> IO HGLOBAL
request h _ = do
  s <- toHsString $ castPtr h
  writeFile "/input" s
  (cstr, n) <- newCStringLen message
  let m = succ n -- '\0'
  _ <- globalFree h
  nh <- globalAlloc gMEM_FIXED (fromIntegral m)
  copyMemory nh (castPtr cstr) (fromIntegral m)
  free cstr
  return nh
  where
    message = "SAORI/1.0 200 OK\r\n" ++
              "Charset: UTF-8\r\n\r\n"

load :: HGLOBAL -> Ptr CLong -> IO Bool
load h _ = do
  cstr <- toHsString $ castPtr h
  writeFile (cstr ++ "hsdll") cstr
  _ <- globalFree h
  return True

unload :: IO Bool
unload = return True

-- | peekCWString はポインタがNULLのときセグフォするのでNULLなら空文字列を返す
toHsString :: CString -> IO String
toHsString s = if s == nullPtr
                       then return ""
                       else peekCString s
