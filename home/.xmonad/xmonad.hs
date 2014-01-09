-- import XMonad
import XMonad
import XMonad.Config.Gnome
import qualified XMonad.StackSet as W
import XMonad.Hooks.SetWMName
import XMonad.Actions.UpdatePointer
import XMonad.Actions.CycleWS
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.ICCCMFocus
import XMonad.Layout.ShowWName
import XMonad.Layout.Accordion
import XMonad.Layout.Spiral
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig
import Data.Ratio ((%))
import XMonad.Actions.Warp
import System.Directory (getHomeDirectory)
import System.IO.Unsafe

main = do
  xmonad $ gnomeConfig
             { manageHook = myManageHook <+> manageHook gnomeConfig
              , workspaces = myWorkspaces
              , modMask    = mod4Mask -- rebind mod to the windows key
              , terminal   = "gnome-terminal"
              , logHook    = takeTopFocus >> setWMName "LG3D" >> updatePointer (Relative 1 1)
             } `additionalKeysP` keys `removeKeysP` removeKeys
      where
        myManageHook :: ManageHook
        myManageHook = composeAll
                       [ manageDocks -- get class name with xprop | grep WM_CLASS
                       , className =? "Firefox"       --> doShift "web"
                       , className =? "google-chrome" --> doShift "web"
                       , className =? "Google-chrome" --> doShift "web"
                       , className =? "gnome-www-browser" --> doShift "web"
                       , className =? "Mumbles"       --> doFloat
                       , className =? "Shutter"       --> doFloat
                       , className =? "gnome-panel"   --> doIgnore
                       , title     =? "Do"            --> doIgnore
                       , isFullscreen --> doFullFloat
                       ]
        {-myLayoutHook = genericLayoutHook-}
        {-genericLayoutHook = avoidStruts $-}
                       {-showWName $-}
                       {-Mirror tall ||| tall ||| simpleTabbed-}
                       {-||| Accordion ||| spiral (0.61)-}
        {-tall = Tall nmaster delta ratio-}
        {-nmaster = 1-}
        {-delta = 3/100-}
        {-ratio = 1/2-}
        -- Remove some keys.
        removeKeys = [ "M-w"
                     , "M-r"
                     ]
        keys = [ ("M-S-z", spawn "gnome-screensaver-command --lock")
               , ("M-S-q", spawn "gnome-session-save --gui --logout-dialog")
               , ("M-S-f", spawn "xdg-open https://duckduckgo.com")
               , ("M-e", spawn "$HOME/bin/e")
               , ("M-<Left>", prevScreen)
               , ("M-<Right>", nextScreen)
               , ("M-S-<Left>", shiftPrevScreen)
               , ("M-S-<Right>", shiftNextScreen)
               , ("M-<Down>", warpToScreen 1 (1%2) (1%2))
               , ("M-<Up>", warpToScreen 0 (1%2) (1%2))
               , ("M-<KP_1>", windows $ W.greedyView "shell")
               ] ++ [ (shift++key, windows $ f i) | (f,shift) <- [ (W.greedyView, "M-") , (W.shift, "M-S-") ], (i,key) <- zip myWorkspaces numPadKeys ]

        -- Cannot use the number versions, as XMonad ignores the numlock state.
        numPadKeys = [ "<KP_End>",  "<KP_Down>",  "<KP_Page_Down>" -- 1, 2, 3
                     , "<KP_Left>", "<KP_Begin>", "<KP_Right>"     -- 4, 5, 6
                     , "<KP_Home>", "<KP_Up>",    "<KP_Page_Up>"   -- 7, 8, 9
                     , "<KP_Insert>"] -- 0
        myWorkspaces = ["shell","web","emacs"] ++ map show [4..9]
