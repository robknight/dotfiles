import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import System.IO
import XMonad.Layout.Tabbed
import XMonad.Actions.GridSelect

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

myGSConfig = defaultGSConfig { gs_cellwidth = 160 }
