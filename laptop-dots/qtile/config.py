import os
import subprocess

from libqtile import bar, layout, widget, hook
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy
from qtile_extras import widget
from qtile_extras.widget.decorations import BorderDecoration, PowerLineDecoration

import colors


mod = "mod4"
alt = "mod1"
terminal = 'alacritty'

keys = [
    # Switch between windows
    Key([mod], "Left", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "Right", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "Down", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "Up", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "space", lazy.layout.next(), desc="Move window focus to other window"),

    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key([mod, "shift"], "Left", lazy.layout.shuffle_left(), desc="Move window to the left"),
    Key([mod, "shift"], "Right", lazy.layout.shuffle_right(), desc="Move window to the right"),
    Key([mod, "shift"], "Down", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "Up", lazy.layout.shuffle_up(), desc="Move window up"),

    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    Key([mod, "control"], "Left", lazy.layout.grow_left(), desc="Grow window to the left"),
    Key([mod, "control"], "Right", lazy.layout.grow_right(), desc="Grow window to the right"),
    Key([mod, "control"], "Down", lazy.layout.grow_down(), desc="Grow window down"),
    Key([mod, "control"], "Up", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),

    #for monadtall
    Key([mod], "equal", lazy.layout.grow(), desc="Grow Window"),
    Key([mod], "minus", lazy.layout.shrink(), desc="Shrink Window"),
                
    #for swtiching monitor windows
    Key([mod], "period", lazy.next_screen(), desc='Move focus to next monitor'),
    Key([mod], "comma", lazy.prev_screen(), desc='Move focus to prev monitor'),
    
    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key(
        [mod, "shift"],
        "Return",
        lazy.layout.toggle_split(),
        desc="Toggle between split and unsplit sides of stack",
    ),
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),

    # Toggle between different layouts as defined below
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod], "w", lazy.window.kill(), desc="Kill focused window"),
    Key(
        [mod],
        "f",
        lazy.window.toggle_fullscreen(),
        desc="Toggle fullscreen on the focused window",
    ),

    #misc. keybinds  
    Key([mod], "t", lazy.window.toggle_floating(), desc="Toggle floating on the focused window"),
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    Key([mod], "r", lazy.spawn("rofi -show drun"), desc="rofi run"),
    Key([alt], "Tab", lazy.spawn("rofi -show window"), desc="alt tab handler"),
    Key([], "XF86MonBrightnessUp",lazy.spawn("brightnessctl s 10+")),
    Key([], "XF86MonBrightnessDown",lazy.spawn("brightnessctl s 10-")),
    Key([], "XF86AudioLowerVolume", lazy.spawn("wpctl set-volume @DEFAULT_AUDIO_SINK@ -l 1 0.1-")),
    Key([], "XF86AudioRaiseVolume", lazy.spawn("wpctl set-volume @DEFAULT_AUDIO_SINK@ -l 1 0.1+")),
    Key([], "XF86AudioMute", lazy.spawn("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")),
    Key([mod, "shift"], "s", lazy.spawn(os.path.expanduser('~/.config/qtile/screenshot.sh'))),
    Key([mod], "l", lazy.spawn('systemctl suspend'))
]

groups = [Group(i) for i in "123456789"]

for i in groups:
    keys.extend(
        [
            # mod1 + letter of group = switch to group
            Key(
                [mod],
                i.name,
                lazy.group[i.name].toscreen(),
                desc="Switch to group {}".format(i.name),
            ),
            # mod1 + shift + letter of group = switch to & move focused window to group
            Key(
                [mod, "shift"],
                i.name,
                lazy.window.togroup(i.name),
                desc="Move focused window to group {}".format(i.name),
            ),
        ]
    )



colors = colors.cat

widget_defaults = dict(
    font="FiraMono Nerd Font",
    fontsize = 16,
    padding = 0,
    background=colors[0]

)

extension_defaults = widget_defaults.copy()


powerline = {
     "decorations": [PowerLineDecoration(path = 'arrow_right')]
}


def widgetsList(main):
    widgetList = [ widget.Prompt(
                     font = "FiraMono Nerd Font",
                     fontsize=14,
                     foreground = colors[2]
            ),
            widget.GroupBox(
                     fontsize = 16,
                     margin_y = 3,
                     margin_x = 4,
                     padding_y = 2,
                     padding_x = 3,
                     borderwidth = 3,
                     active = colors[8],
                     inactive = colors[3],
                     rounded = True,
                     highlight_color = colors[1],
                     highlight_method = "line",
                     this_current_screen_border = colors[7],
                     this_screen_border = colors [4],
                     other_current_screen_border = colors[7],
                     other_screen_border = colors[4],
                     ),
            widget.TextBox(
                     text = '|',
                     font = "FiraMono Nerd Font",
                     foreground = colors[2],
                     padding = 2,
                     fontsize = 14
                     ),
            widget.CurrentLayoutIcon(
                     # custom_icon_paths = [os.path.expanduser("~/.config/qtile/icons")],
                     foreground = colors[2],
                     padding = 0,
                     scale = 0.7
                     ),
            widget.CurrentLayout(
                     foreground = colors[2],
                     padding = 5
                     ),
            widget.TextBox(
                     text = '|',
                     font = "FiraMono Nerd Font",
                     foreground = colors[2],
                     padding = 2,
                     fontsize = 14
                     ),
            widget.WindowName(
                     foreground = colors[4],
                     max_chars = 40
                     ),



            widget.Spacer(length = 8, **powerline),
            
            widget.GenPollText(
                     update_interval = 300,
                     func = lambda: subprocess.check_output("printf $(uname -r)", shell=True, text=True),
                     background = colors[4],
                     fmt = '{} ',
                     **powerline
                     ),
                     
            widget.Wlan(
                interface = 'wlo1',
                background = colors[5],
                **powerline,
                mouse_callbacks = { 'Button1': lazy.spawn("nm-connection-editor")}
            ),
             widget.Bluetooth( 
                        #device='/dev_95_05_BB_2F_7F_88',
                        fmt='󰂱 {} ',

                        default_show_battery=True,


                        background=colors[6],
                        **powerline, 
                        mouse_callbacks = { 'Button1': lazy.spawn("rfkill toggle bluetooth") , 'Button3': lazy.spawn("blueman-manager")}
            ),
            widget.Volume(
                    background = colors[7],
                    emoji=False,
                    fmt='󰕾  {} ',
                    emoji_list=['󰖁 ', '', '󰕾', ''],

                    **powerline,
                     mouse_callbacks = { 'Button1': lazy.spawn("pavucontrol")}
            ),
            widget.Battery(
                charge_char='󰂄',
                discharge_char='󰁿',
                full_char='󱟢',
                
                low_percentage=0.15,
                low_background=colors[10],
                notification_timeout=10,
                notify_below=0.15,

                update_interval=30,
                show_short_text=False,
                
                format='{char} {percent:2.0%} ',
                background=colors[8],
                **powerline
            ),
             widget.Clock(
                     background = colors[9],
                     format = "%m-%d %H:%M ",
                     **powerline
                     ),
            widget.Spacer(length = 8)
            ]
    
    if main:
        widgetList.append(widget.Systray(padding = 3))
        widgetList.append(widget.Spacer(length = 8))
    return widgetList

def initScreens():
    return [Screen(top=bar.Bar(widgets=widgetsList(True), size=26, background="#00000000"),  wallpaper = '/home/neutron/Pictures/wallpapers/fortuna.png', wallpaper_mode='fill')]


screens = initScreens()

# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]



layout_theme = {"border_width": 3,
                              "margin": 8,
                              "border_focus": colors[4],
                              "border_normal": colors[1]
                             }
layouts = [
  layout.MonadTall(**layout_theme),
  layout.Max(**layout_theme),
  layout.Floating(**layout_theme),
]

floating_layout = layout.Floating(**layout_theme,
  float_rules=[
     *layout.Floating.default_float_rules,
     Match(wm_class='confirmreset'),
  ])


@hook.subscribe.startup_once
def autostart():
	startscript = os.path.expanduser('~/.config/qtile/autostart.sh')
	subprocess.Popen([startscript])






#-------------------------------------------------------

dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = True
bring_front_click = False
floats_kept_above = True
cursor_warp = False

auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

# When using the Wayland backend, this can be used to configure input devices.
wl_input_rules = None

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"
