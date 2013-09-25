{-# LANGUAGE NoMonomorphismRestriction #-}
import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import System.IO
import XMonad.Layout.Tabbed
import XMonad.Actions.GridSelect
import qualified Data.Map as M

myManagementHooks :: [ManageHook]
myManagementHooks = [
  resource =? "stalonetray" --> doIgnore
  ]


main = do
    xmproc <- spawnPipe "/usr/bin/xmobar /home/rknight/.xmobarrc"

    xmonad =<< xmobar myConfig

myConfig = defaultConfig
        { manageHook = manageDocks <+> manageHook defaultConfig <+> composeAll myManagementHooks
        , layoutHook = avoidStruts  $  layoutHook defaultConfig
        , logHook = dynamicLogWithPP $ xmobarPP
        , modMask = mod4Mask     -- Rebind Mod to the Windows key
        }
        `additionalKeys`
        [ ((mod4Mask, xK_g), goToSelected myGSConfig) ]

myGSConfig = defaultGSConfig { gs_cellwidth = 250
                             , gs_navigate = myNavigation
                             , gs_font = "xft:Bitstream Vera Sans-10"
                             }

myNavigation :: TwoD a (Maybe a)
myNavigation = makeXEventhandler $ shadowWithKeymap navKeyMap navDefaultHandler
 where navKeyMap = M.fromList [
          ((0,xK_Escape), cancel)
         ,((0,xK_Return), select)
         ,((0,xK_g), select)
         ,((0,xK_slash) , substringSearch myNavigation)
         ,((0,xK_Left)  , move (-1,0)  >> myNavigation)
         ,((0,xK_h)     , move (-1,0)  >> myNavigation)
         ,((0,xK_Right) , move (1,0)   >> myNavigation)
         ,((0,xK_l)     , move (1,0)   >> myNavigation)
         ,((0,xK_Down)  , move (0,1)   >> myNavigation)
         ,((0,xK_j)     , move (0,1)   >> myNavigation)
         ,((0,xK_k)     , move (0,-1)   >> myNavigation)
         ,((0,xK_Up)    , move (0,-1)  >> myNavigation)
         ,((0,xK_y)     , move (-1,-1) >> myNavigation)
         ,((0,xK_i)     , move (1,-1)  >> myNavigation)
         ,((0,xK_n)     , move (-1,1)  >> myNavigation)
         ,((0,xK_m)     , move (1,-1)  >> myNavigation)
         ,((0,xK_space) , setPos (0,0) >> myNavigation)
         ]
       -- The navigation handler ignores unknown key symbols
       navDefaultHandler = const myNavigation
