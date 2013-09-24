import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import System.IO
import XMonad.Layout.Tabbed

myManagementHooks :: [ManageHook]
myManagementHooks = [
  resource =? "stalonetray" --> doIgnore
  ]


main = do
    xmproc <- spawnPipe "/usr/bin/xmobar /home/rknight/.xmobarrc"

    xmonad =<< xmobar defaultConfig
        { manageHook = manageDocks <+> manageHook defaultConfig <+> composeAll myManagementHooks
        , layoutHook = avoidStruts  $  layoutHook defaultConfig
        , logHook = dynamicLogWithPP $ xmobarPP
        , modMask = mod4Mask     -- Rebind Mod to the Windows key
        }
