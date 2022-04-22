import XMonad
import System.Exit (exitSuccess)
import qualified XMonad.StackSet as W

import XMonad.Actions.CopyWindow (kill1)
import XMonad.Actions.CycleWS (Direction1D(..), moveTo, shiftTo, WSType(..), nextScreen, prevScreen)
import XMonad.Actions.Promote
import XMonad.Actions.RotSlaves (rotSlavesDown, rotAllDown)
import XMonad.Actions.WithAll (sinkAll, killAll)
import XMonad.Actions.WindowGo (runOrRaise)

import qualified Data.Map as M

import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP
import XMonad.Hooks.SetWMName

import XMonad.Util.EZConfig
import XMonad.Util.Loggers
import XMonad.Util.Ungrab
import XMonad.Util.SpawnOnce

import XMonad.Actions.MouseResize
import XMonad.Layout.Magnifier
import XMonad.Layout.ThreeColumns
import XMonad.Layout.LimitWindows (limitWindows, increaseLimit, decreaseLimit)
import XMonad.Layout.MultiToggle.Instances (StdTransformers(NBFULL, MIRROR, NOBORDERS))
import qualified XMonad.Layout.ToggleLayouts as T (toggleLayouts, ToggleLayout(Toggle))
import qualified XMonad.Layout.MultiToggle as MT (Toggle(..))
import XMonad.Layout.ResizableTile

import XMonad.Hooks.EwmhDesktops

import Colors.DoomOne

myTerminal :: String
myTerminal = "alacritty "

myBrowser :: String
myBrowser = "librewolf"

myEmacs :: String
myEmacs = "emacsclient -c -a 'emacs'"

main :: IO ()
main = xmonad
     . ewmh
     . withEasySB (statusBarProp "xmobar" (pure myXmobarPP)) defToggleStrutsKey
     $ myConfig

myStartupHook :: X ()
myStartupHook = do
    spawn "killall trayer > /dev/null 2>&1"  -- kill current trayer on each restart
    spawn "sh -c '$HOME/.screenlayout/onkyo_samsung_zowie.sh'"
    spawn "xmodmap $HOME/.Xmodmap"
    spawn "xinput --set-prop 'Logitech Gaming Mouse G502' 'libinput Accel Profile Enabled' 0, 1"

    spawnOnce "/usr/bin/emacs --daemon" -- emacs daemon for the emacsclient

    spawn ("sleep 2 && trayer --edge top --align right --widthtype request --padding 6 --SetDockType true --SetPartialStrut true --expand true --monitor 1 --transparent true --alpha 0 " ++ colorTrayer ++ " --height 18")

    -- spawnOnce "feh --randomize --bg-fill ~/wallpapers/*"  -- feh set random wallpaper
    -- spawnOnce "nitrogen --restore &"   -- if you prefer nitrogen to feh
    setWMName "LG3D"

myConfig = def
    { modMask    = mod4Mask  -- mod4Mask = Super (Win), mod1Mask = Left-Alt
    , layoutHook = avoidStruts $ mouseResize myLayout      -- Use custom layouts
    , manageHook = myManageHook  -- Match on certain windows
    , startupHook = myStartupHook
    , workspaces = myWorkspaces
    }
  `additionalKeysP`
        -- KB_GROUP Xmonad
        [ ("M-S-r", spawn "xmonad --recompile; xmonad --restart")  -- Restarts xmonad
        , ("M-S-q", io exitSuccess)                   -- Quits xmonad

    -- KB_GROUP Run Prompt
        , ("M-p", spawn "dmenu_run") -- Dmenu

    -- KB_GROUP Useful programs to have a keybinding for launch
        , ("M-S-<Return>", spawn (myTerminal))
        , ("M-]", spawn (myBrowser))
        , ("M-M4-h", spawn (myTerminal ++ " -e htop"))
	, ("M-=", spawn "scrot -s")

    -- KB_GROUP Kill windows
        , ("M-S-c", kill1)     -- Kill the currently focused client
        , ("M-S-a", killAll)   -- Kill all windows on current workspace

    -- KB_GROUP Workspaces
        , ("M-.", nextScreen)  -- Switch focus to next monitor
        , ("M-,", prevScreen)  -- Switch focus to prev monitor

    -- KB_GROUP Floating windows
        , ("M-t", withFocused $ windows . W.sink)  -- Push floating window back to tile
        , ("M-S-t", sinkAll)                       -- Push ALL floating windows to tile

    -- KB_GROUP Windows navigation
        , ("M-m", windows W.focusMaster)  -- Move focus to the master window
        , ("M-j", windows W.focusDown)    -- Move focus to the next window
        , ("M-k", windows W.focusUp)      -- Move focus to the prev window
        , ("M-S-m", windows W.swapMaster) -- Swap the focused window and the master window
        , ("M-S-j", windows W.swapDown)   -- Swap focused window with next window
        , ("M-S-k", windows W.swapUp)     -- Swap focused window with prev window
        , ("M-S-<Backspace>", promote)      -- Moves focused window to master, others maintain order
        , ("M-S-<Tab>", rotSlavesDown)    -- Rotate all windows except master and keep focus in place
        , ("M-C-<Tab>", rotAllDown)       -- Rotate all the windows in the current stack

    -- KB_GROUP Layouts
        , ("M-f", sendMessage (T.Toggle "Full"))
        , ("M-<Tab>", sendMessage NextLayout)           -- Switch to next layout
        , ("M-<Space>", sendMessage (MT.Toggle NBFULL) >> sendMessage ToggleStruts) -- Toggles noborder/full

    -- KB_GROUP Increase/decrease windows in the master pane or the stack
        , ("M-S-<Up>", sendMessage (IncMasterN 1))      -- Increase # of clients master pane
        , ("M-S-<Down>", sendMessage (IncMasterN (-1))) -- Decrease # of clients master pane
        , ("M-C-<Up>", increaseLimit)                   -- Increase # of windows
        , ("M-C-<Down>", decreaseLimit)                 -- Decrease # of windows

    -- KB_GROUP Window resizing
        , ("M-S-h", sendMessage Shrink)                   -- Shrink horiz window width
        , ("M-S-l", sendMessage Expand)                   -- Expand horiz window width
        , ("M-M1-j", sendMessage MirrorShrink)          -- Shrink vert window width
        , ("M-M1-k", sendMessage MirrorExpand)          -- Expand vert window width

    -- KB_GROUP Controls for mocp music player (SUPER-u followed by a key)
        , ("M-u p", spawn "mocp --play")
        , ("M-u l", spawn "mocp --next")
        , ("M-u h", spawn "mocp --previous")
        , ("M-u <Space>", spawn "mocp --toggle-pause")

    -- KB_GROUP Emacs (SUPER-e followed by a key)
        , ("M-e e", spawn (myEmacs))                             -- emacs dashboard
        , ("M-e b", spawn (myEmacs ++ ("--eval '(ibuffer)'")))   -- list buffers
        , ("M-e d", spawn (myEmacs ++ ("--eval '(dired nil)'"))) -- dired
        , ("M-e i", spawn (myEmacs ++ ("--eval '(erc)'")))       -- erc irc client
        , ("M-e n", spawn (myEmacs ++ ("--eval '(elfeed)'")))    -- elfeed rss
        , ("M-e s", spawn (myEmacs ++ ("--eval '(eshell)'")))    -- eshell
        , ("M-e t", spawn (myEmacs ++ ("--eval '(mastodon)'")))  -- mastodon.el
        , ("M-e v", spawn (myEmacs ++ ("--eval '(+vterm/here nil)'"))) -- vterm if on Doom Emacs
        , ("M-e w", spawn (myEmacs ++ ("--eval '(doom/window-maximize-buffer(eww \"distro.tube\"))'"))) -- eww browser if on Doom Emacs
        , ("M-e a", spawn (myEmacs ++ ("--eval '(emms)' --eval '(emms-play-directory-tree \"~/Music/\")'")))

    -- KB_GROUP Multimedia Keys
        , ("<XF86AudioPlay>", spawn "mocp --play")
        , ("<XF86AudioPrev>", spawn "mocp --previous")
        , ("<XF86AudioNext>", spawn "mocp --next")
        , ("<XF86AudioMute>", spawn "amixer set Master toggle")
        , ("<XF86AudioLowerVolume>", spawn "amixer set Master 5%- unmute")
        , ("<XF86AudioRaiseVolume>", spawn "amixer set Master 5%+ unmute")
        , ("<XF86HomePage>", spawn "qutebrowser https://www.youtube.com/c/DistroTube")
        , ("<XF86Search>", spawn "dm-websearch")
        , ("<XF86Mail>", runOrRaise "thunderbird" (resource =? "thunderbird"))
        , ("<XF86Calculator>", runOrRaise "qalculate-gtk" (resource =? "qalculate-gtk"))
        , ("<XF86Eject>", spawn "toggleeject")
        , ("<Print>", spawn "dm-maim")
        ]
-- END_KEYS

myManageHook :: ManageHook
myManageHook = composeAll
    [ className =? "Gimp" --> doFloat
    , isDialog            --> doFloat
    ]

myLayout = T.toggleLayouts Full (tiled ||| Mirror tiled ||| threeCol)
  where
    threeCol = magnifiercz' 1.3 $ ThreeColMid nmaster delta ratio
    tiled    = Tall nmaster delta ratio
    nmaster  = 1      -- Default number of windows in the master pane
    ratio    = 1/2    -- Default proportion of screen occupied by master pane
    delta    = 3/100  -- Percent of screen to increment by when resizing panes

-- myWorkspaces = [" 1 ", " 2 ", " 3 ", " 4 ", " 5 ", " 6 ", " 7 ", " 8 ", " 9 "]
myWorkspaces = [" dev ", " www ", " sys ", " doc ", " chat ", " game ", " mus ", " vid ", " vbox "]
--myWorkspaceIndices = M.fromList $ zipWith (,) myWorkspaces [1..] -- (,) == \x y -> (x,y)

myXmobarPP :: PP
myXmobarPP = def
    { ppSep             = magenta " • "
    , ppTitleSanitize   = xmobarStrip
    , ppCurrent         = wrap " " "" . xmobarBorder "Top" "#8be9fd" 2
    , ppHidden          = white . wrap " " ""
    , ppHiddenNoWindows = lowWhite . wrap " " ""
    , ppUrgent          = red . wrap (yellow "!") (yellow "!")
    , ppOrder           = \[ws, l, _, wins] -> [ws, l, wins]
    , ppExtras          = [logTitles formatFocused formatUnfocused]
    }
  where
    formatFocused   = wrap (white    "[") (white    "]") . magenta . ppWindow
    formatUnfocused = wrap (lowWhite "[") (lowWhite "]") . blue    . ppWindow

    -- | Windows should have *some* title, which should not not exceed a
    -- sane length.
    ppWindow :: String -> String
    ppWindow = xmobarRaw . (\w -> if null w then "untitled" else w) . shorten 30

    blue, lowWhite, magenta, red, white, yellow :: String -> String
    magenta  = xmobarColor "#ff79c6" ""
    blue     = xmobarColor "#bd93f9" ""
    white    = xmobarColor "#f8f8f2" ""
    yellow   = xmobarColor "#f1fa8c" ""
    red      = xmobarColor "#ff5555" ""
    lowWhite = xmobarColor "#bbbbbb" ""
