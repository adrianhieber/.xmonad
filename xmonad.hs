-- Imports

import XMonad
import Data.Monoid
import Data.Maybe (fromJust, fromMaybe)
import System.Exit
import XMonad.Actions.GridSelect
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run
import XMonad.Layout.Spacing
import XMonad.Layout.NoBorders
import XMonad.Util.SpawnOnce
import XMonad.Operations
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageHelpers --for center floar or doRectfloat
import XMonad.Hooks.EwmhDesktops
import qualified XMonad.StackSet as W
import qualified Data.Map        as M
import System.IO


-- The preferred terminal program, which is used in a binding below and by
-- certain contrib modules.
--
myTerminal      = "tilix"
--myTerminal      = "gnome-terminal"


-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- Whether clicking on a window to focus also passes the click to the window
myClickJustFocuses :: Bool
myClickJustFocuses = False

-- Width of the window border in pixels.
--
myBorderWidth   = 2

-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
-- mod1Mask ist Alt+Shift
--
myModMask       = mod4Mask

-- The default number of workspaces (virtual screens) and their names.
-- By default we use numeric strings, but any string may be used as a
-- workspace name. The number of workspaces is determined by the length
-- of this list.
--
-- A tagging example:
--
-- > workspaces = ["web", "irc", "code" ] ++ map show [4..9]
--
myWorkspaces    = ["dev", "www","file","sys","doc","misc","mus","vid","chat"]
  
myWorkspaceIndices = M.fromList $ zipWith (,) myWorkspaces [1..] -- (,) == \x y -> (x,y)

clickable ws = "<action=xdotool key super+"++show i++">"++ws++"</action>"
    where i = fromJust $ M.lookup ws myWorkspaceIndices


-- Border colors for unfocused and focused windows, respectively.
--
myNormalBorderColor  = "#007582" --orange "#d1a51f" --violet: "#f542f5"--blue: "#0667bd" --default: "#dddddd"
myFocusedBorderColor = "#00e5ff" --green: "#33ff3d" --default: "#ff0000"


windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset



centerWindow :: Window -> X ()
centerWindow win = do
    (_, W.RationalRect x y w h) <- floatLocation win
    windows $ W.float win (W.RationalRect ((1 - w) / 2) ((1 - h) / 2) w h)
    return ()


------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--

--own gridselect for own names
spawnSelected' :: [(String, String)] -> X ()
spawnSelected' lst = gridselect conf lst >>= flip whenJust spawn
  where conf = defaultGSConfig
  
toggleFloat w = windows (\s -> if M.member w (W.floating s)
	then W.sink w s
	--(hochizont start) (vertikal start) (hochizontential size) (vertikal size)
	else (W.float w (W.RationalRect (1/140) (1/40) (1/2) (1/2)) s))

  
  
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

    -- launch a terminal
    [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)

    -- launch dmenu
    , ((modm,               xK_p     ), spawn "dmenu_run")
    
    
    -- launch gridselect (eigen)
     , ((modm, xK_s), spawnSelected'
      [("","") --do nothing
      ,("Firefox", "firefox")
      ,("Files","nautilus")
      ,("Rechner","gnome-calculator")
      ,("Kalender","gnome-calendar")
      ,("Editor","gnome-text-editor")
      ,("Einstellungen","gnome-control-center")
      ,("Xmonad","gnome-text-editor .xmonad/xmonad.hs")
      ,("XmonadBar","gnome-text-editor .xmonad/xmobar/xmobar.config")
      ,("XJounal","xournalpp")
      --,("Ausloggen","pkill -SIGKILL -u adrian")
      ,("Herunterfahren","shutdown --poweroff now")
      ,("eDex-UI","~/eDEX-UI.Linux.x86_64.AppImage")
      ,("Tililx", "tilix")])
     

    -- launch gmrun
    , ((modm .|. shiftMask, xK_p     ), spawn "gmrun")
    
    --make float center
    , ((modm .|. shiftMask, xK_m     ), withFocused centerWindow)
    
    , ((modm .|. shiftMask , xK_k     ), spawn "gnome-calendar")
    , ((modm .|. shiftMask , xK_n     ), spawn "nautilus")
    --, ((modm .|. shiftMask , xK_m    ), spawn ". /home/adrian/.config/htop/htop.sh")

    -- close focused window
    , ((modm , xK_c     ), kill)
    , ((modm .|. shiftMask , xK_c     ), kill)

     -- Rotate through the available layout algorithms
    , ((modm,               xK_space ), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- Resize viewed windows to the correct size
    , ((modm,               xK_n     ), refresh)
    
    -- Toggle focued windows for float 
    , ((modm,               xK_f     ), withFocused toggleFloat)

    -- Move focus to the next window
    , ((modm,               xK_Tab   ), windows W.focusDown)

    -- Move focus to the next window
    , ((modm,               xK_Down     ), windows W.focusDown)

    -- Move focus to the previous window
    , ((modm,               xK_Up     ), windows W.focusUp  )

    -- Move focus to the master window
    , ((modm,               xK_m     ), windows W.focusMaster  )

    -- Swap the focused window and the master window
    , ((modm,               xK_Return), windows W.swapMaster)

    -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_Down     ), windows W.swapDown  )

    -- Swap the focused window with the previous window
    , ((modm .|. shiftMask, xK_Up     ), windows W.swapUp    )

    -- Shrink the master area
    , ((modm .|. shiftMask, xK_Left     ), sendMessage Shrink)

    -- Expand the master area
    , ((modm .|. shiftMask, xK_Right     ), sendMessage Expand)

    -- Push window back into tiling
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)

    -- Increment the number of windows in the master area
    --, ((modm              , xK_comma ), sendMessage (IncMasterN 1))
    , ((modm              , xK_plus ), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    --, ((modm              , xK_period), sendMessage (IncMasterN (-1)))
    , ((modm              , xK_minus), sendMessage (IncMasterN (-1)))

    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    --
    -- , ((modm              , xK_b     ), sendMessage ToggleStruts)

    -- Quit xmonad
    , ((modm .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))

    -- Restart xmonad
    , ((modm              , xK_q     ), spawn "xmonad --recompile; xmonad --restart")

    -- Run xmessage with a summary of the default keybindings (useful for beginners)
    --, ((modm .|. shiftMask, xK_slash ), spawn ("echo \"" ++ help ++ "\" | xmessage -file -"))
    , ((modm, xK_h ), spawn ("echo \"" ++ help ++ "\" | xmessage -file -"))
    ]
    ++

    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++

    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]


------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- Layouts:

-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--
--spacing 5 heist 5 pixel zwischen windows
-- spacing 5 $ heist ueberall abstand 5 (auch full)
--
--myLayout = avoidStruts (spacing 4 tiled ||| Mirror tiled ||| Full)
myLayout = avoidStruts ( noBorders Full ||| spacing pixels tiled )
  where
     pixels = 4
     
     
     -- default tiling algorithm partitions the screen into two panes
     tiled   = Tall nmaster delta ratio

     -- The default number of windows in the master pane
     nmaster = 1

     -- Default proportion of screen occupied by master pane
     ratio   = 1/2

     -- Percent of screen to increment by when resizing panes
     delta   = 3/100

------------------------------------------------------------------------
-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
myManageHook = composeAll
    [ className =? "MPlayer"        --> doFloat
    , className =? "Gimp"           --> doFloat
    , title =? "volume_adjuster"           --> (doRectFloat $ W.RationalRect 0.87 0.025 0.1 0.1)
    --, title =? "Calendar"           --> doFullFloat
    ,isFullscreen --> doFullFloat
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore ]

------------------------------------------------------------------------
-- Event handling

-- * EwmhDesktops users should change this to ewmhDesktopsEventHook
--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
myEventHook = XMonad.Hooks.EwmhDesktops.fullscreenEventHook

------------------------------------------------------------------------
-- Status bars and logging

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--
myLogHook = return ()

------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing:
-- myStartupHook = return ()
--
myStartupHook = do
	spawnOnce "compton &"
	spawnOnce "nitrogen --restore &" --for wallpaper
	spawnOnce ". /home/adrian/.config/.startup_program.sh"
	--spawnOnce "nitrogen --set-zoom-fill /home/adrian/Bilder/wallpaper/island.jpg"
	

------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.

-- Run xmonad with the settings you specify. No need to modify this.
--
-- default: main = xmonad defaults
--
main = do
	xmproc <- spawnPipe "xmobar -x 0 /home/adrian/.xmonad/xmobar/xmobar.config"
	xmonad $ docks $ defaults{
		logHook = dynamicLogWithPP xmobarPP
		                { ppOutput = hPutStrLn xmproc
		                --, ppCurrent = xmobarColor "yellow" "" . wrap "[" "]"
		                , ppCurrent = xmobarColor "#98be65" "" . wrap " [" "] "
                      		--, ppVisible = wrap "(" ")"
                      		, ppVisible = xmobarColor "#98be65" "" . clickable
                      		, ppHidden = xmobarColor "#82AAFF" "" . wrap " *" " " . clickable
		                --, ppHiddenNoWindows = xmobarColor "grey" ""
		                , ppHiddenNoWindows = xmobarColor "#C792EA" "" . wrap " " " " . clickable
		                --, ppTitle   = xmobarColor "green"  "" . shorten 40
		                , ppTitle   = xmobarColor "#B3AFC2"  "" . shorten 60
		                --, ppUrgent  = xmobarColor "red" "yellow"
		                , ppUrgent = xmobarColor "#C45500" "" . wrap "!" "!"
		                , ppExtras  = [windowCount]
		                , ppSep =  "  |  "
		                --, ppOrder  = \(ws:l:t:ex) -> [ws,l]++ex++[t] 
		                --without window spacing:
		                , ppOrder  = \(ws:l:t:ex) -> [ws]++ex++[t]
		                }
	}

-- A structure containing your configuration settings, overriding
-- fields in the default config. Any you don't override, will
-- use the defaults defined in xmonad/XMonad/Config.hs
--
-- No need to modify this.
--
defaults = def {
      -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        clickJustFocuses   = myClickJustFocuses,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

      -- key bindings
        keys               = myKeys,
        mouseBindings      = myMouseBindings

      -- hooks, layouts
        ,layoutHook         = myLayout
        ,manageHook         = myManageHook
        ,handleEventHook    = myEventHook
        ,startupHook        = myStartupHook
        , logHook	    = myLogHook
    }

-- | Finally, a copy of the default bindings in simple textual tabular format.
help :: String
help = unlines ["The default modifier key is 'alt'. Default keybindings:",
    "",
    "-- launching and killing programs",
    "mod-Shift-Enter  Launch xterminal",
    "mod-p            Launch dmenu",
    "mod-Shift-p      Launch gmrun",
    "mod-Shift-c      Close/kill the focused window",
    "mod-Space        Rotate through the available layout algorithms",
    "mod-Shift-Space  Reset the layouts on the current workSpace to default",
    "mod-n            Resize/refresh viewed windows to the correct size",
    "",
    "-- move focus up or down the window stack",
    "mod-Tab        Move focus to the next window",
    "mod-Shift-Tab  Move focus to the previous window",
    "mod-j          Move focus to the next window",
    "mod-k          Move focus to the previous window",
    "mod-m          Move focus to the master window",
    "",
    "-- modifying the window order",
    "mod-Return   Swap the focused window and the master window",
    "mod-Shift-j  Swap the focused window with the next window",
    "mod-Shift-k  Swap the focused window with the previous window",
    "",
    "-- resizing the master/slave ratio",
    "mod-h  Shrink the master area",
    "mod-l  Expand the master area",
    "",
    "-- floating layer support",
    "mod-t  Push window back into tiling; unfloat and re-tile it",
    "",
    "-- increase or decrease number of windows in the master area",
    "mod-comma  (mod-,)   Increment the number of windows in the master area",
    "mod-period (mod-.)   Deincrement the number of windows in the master area",
    "",
    "-- quit, or restart",
    "mod-Shift-q  Quit xmonad",
    "mod-q        Restart xmonad",
    "mod-[1..9]   Switch to workSpace N",
    "",
    "-- Workspaces & screens",
    "mod-Shift-[1..9]   Move client to workspace N",
    "mod-{w,e,r}        Switch to physical/Xinerama screens 1, 2, or 3",
    "mod-Shift-{w,e,r}  Move client to screen 1, 2, or 3",
    "",
    "-- Mouse bindings: default actions bound to mouse events",
    "mod-button1  Set the window to floating mode and move by dragging",
    "mod-button2  Raise the window to the top of the stack",
    "mod-button3  Set the window to floating mode and resize by dragging"]
