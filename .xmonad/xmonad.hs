-- This configuration depends on xmonad=0.15 and xmonad-contrib=0.16
import XMonad
import XMonad.Hooks.EwmhDesktops

-- Used for xmobar
import XMonad.Hooks.DynamicLog
import XMonad.Util.Loggers -- For showing window titles
import XMonad.Util.Font -- For aligning text in window titles
--import XMonad.Util.ClickableWorkspaces -- For clickable workspaces (nothing else is clickable...)

-- Imports for layouts
import XMonad.Layout.NoBorders -- For removing borders on layouts with smartBorders
import XMonad.Layout.Renamed -- For renaming layouts

--import XMonad.Operations -- For basic window manager operations
import XMonad.Util.EZConfig (additionalKeysP)
import System.Exit -- required for quitting xmonad

-- For changing window management
import XMonad.Hooks.ManageHelpers -- Includes basic policies for window rules

myConfig = def
           { terminal           = myTerminal,
             modMask            = myModMask,
             borderWidth        = myBorderWidth,
             focusedBorderColor = myFocusedBorderColor,
             normalBorderColor  = myNormalBorderColor,
             startupHook        = myStartupHook,
             layoutHook         = myLayout,    -- Use custom layouts
             manageHook         = myManageHook, -- Change window management on custom matches
             handleEventHook    = fullscreenEventHook -- Support fullscreen using Ewmh standards
           }
           `additionalKeysP` myKeys

myKeys :: [(String, X ())]
myKeys =
  [ ("M-]",   spawn "google-chrome-stable"),
    ("M-q",   kill),                                          -- close the focused window
    ("M-S-q", io exitSuccess),                                -- quit xmonad
    ("M-S-r", spawn "xmonad --recompile && xmonad --restart") -- recompile and restart xmonad
  ]

--myTerminal           = "st"
myTerminal           = "kitty"
myModMask            = mod4Mask -- Win key or Super_L
myBorderWidth        = 1
myFocusedBorderColor = "#6699cc"
myNormalBorderColor  = "#444444"

--
-- LAYOUTS
--
myLayout = myFull ||| myTall
  where
    myTall   = renamed [Replace "TALL"] $ smartBorders $ Tall nmaster delta ratio
    myFull   = renamed [Replace "FULL"] $ smartBorders $ Full
    nmaster  = 1      -- Default number of windows in the master pane
    ratio    = 1/2    -- Default proportion of screen occupied by master pane
    delta    = 3/100  -- Percent of screen to increment by when resizing panes

myXmobarPP :: PP
myXmobarPP = def
  { ppCurrent         = blue . wrap " " "",
    ppHidden          = brightWhite . wrap " " "",
    ppHiddenNoWindows = white . wrap " " "",
    ppUrgent          = red . wrap (yellow "!") (yellow "!"),
    ppSep             = blue " • ",
    ppTitleSanitize   = xmobarStrip,
    ppOrder           = \[ws, l, _, wins] -> [ws, l, wins],
    --ppExtras          = [logTitles formatFocused formatUnfocused]
    ppExtras          = [lTitle]
  }
  where
    lTitle = fixedWidthL AlignLeft "." 99 <$> dzenColorL "cornsilk3" "" <$> padL . shortenL 80 $ logTitle
    -- formatFocused   = wrap (brightWhite "[") (brightWhite    "]") . blue  . ppWindow
    -- formatUnfocused = wrap (white       "[") (white          "]") . white . ppWindow
    -- Windows should have *some* title, which should not not exceed a sane length
    -- TODO make each window the same size in the bar
    -- TODO make workspaces a bit clearer if they're occupied or not..
    ppWindow :: String -> String
    ppWindow    = xmobarRaw . (\w -> if null w then "untitled" else w) . shorten 30
    blue, white, magenta, red, brightWhite, yellow :: String -> String
    magenta     = xmobarColor "#ff79c6" ""
    blue        = xmobarColor "#6699cc" ""
    white       = xmobarColor "#d3d0c8" ""
    yellow      = xmobarColor "#f1fa8c" ""
    red         = xmobarColor "#ff5555" ""
    brightWhite = xmobarColor "#f2f0ec" ""

myManageHook :: ManageHook
myManageHook = composeAll
  [ className =? "Pavucontrol" --> doCenterFloat,
    className =? "Xarchiver"   --> doCenterFloat,
    isDialog                   --> doCenterFloat
  ]

-- Start xmonad-specific applications, applications that are common to
-- all my window-managers are started in ~/.xprofile
myStartupHook :: X ()
myStartupHook = do
  spawn "$HOME/.xmonad/systray.sh &" -- System tray

-- Key binding to toggle the gap for the bar
toggleStrutsKey XConfig {XMonad.modMask = modMask} = (modMask, xK_b)

--
-- MAIN
--
main :: IO ()
main = xmonad . ewmh =<< statusBar "xmobar ~/.config/xmobar/xmobarrc" (myXmobarPP) toggleStrutsKey myConfig
