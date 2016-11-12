{-# LANGUAGE ForeignFunctionInterface #-}
module DllSaori where

import Foreign.C.String
import Foreign.C.Types (CUInt(..))
import Foreign.Marshal.Alloc
import Foreign.Ptr (nullPtr, Ptr, castPtr)
import System.Win32.Mem

import qualified Saori

foreign import stdcall "windows.h GlobalFree" gFree :: HGLOBAL -> IO ()

foreign export ccall load :: HGLOBAL -> CUInt -> IO Bool
foreign export ccall unload :: IO Bool
foreign export ccall request :: HGLOBAL -> Ptr CUInt -> IO HGLOBAL

request :: HGLOBAL -> Ptr CUInt -> IO HGLOBAL
request h _ = do
  s <- toHsString $ castPtr h
  appendFile "request" s
  let message = Saori.request s
  (cstr, n) <- newCStringLen message
  let m = succ n -- '\0'
  gFree h
  nh <- globalAlloc gMEM_FIXED (fromIntegral m)
  copyMemory nh (castPtr cstr) (fromIntegral m)
  free cstr
  return nh

load :: HGLOBAL -> CUInt -> IO Bool
load h _ = do
  cstr <- toHsString $ castPtr h
  writeFile (cstr ++ "hsdll") cstr
  gFree h
  return True

unload :: IO Bool
unload = return True

-- | peekCWString はポインタがNULLのときセグフォするのでNULLなら空文字列を返す
toHsString :: CString -> IO String
toHsString s = if s == nullPtr
                       then return ""
                       else peekCString s
