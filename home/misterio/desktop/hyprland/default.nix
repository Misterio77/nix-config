{ lib, config, pkgs, ... }:
{
  imports = [
    ../common
    ../common/wayland-wm
  ];

  home.packages = with pkgs; [
    hyprland
    mako
    primary-xwayland
    sway-contrib.grimshot
    pulseaudio
    light
    swaybg
    swayidle
    swaylock-effects
  ];

  xdg.configFile."hypr/hyprland.conf".text =
    let
      inherit (config.colorscheme) colors;
      inherit (config.home.preferredApps)
        menu browser editor mail notifier terminal;
    in
    ''
      monitor=eDP-1,1920x1080@60,0x0,1
      workspace=eDP-1,1

      monitor=DP-3,1920x1080@60,0x0,1
      workspace=DP-3,3
      monitor=DP-1,2560x1080@75,1920x65,1
      workspace=DP-1,1
      monitor=DP-2,1920x1080@60,4480x0,1
      workspace=DP-2,2

      general {
        main_mod=SUPER
        gaps_in=15
        gaps_out=20
        border_size=2.7
        col.active_border=0xff${colors.base0C}
        col.inactive_border=0xff${colors.base02}
      }

      decoration {
        active_opacity=0.96
        inactive_opacity=0.8
        fullscreen_opacity=1.0
        rounding=3
        blur=1
        blur_size=5
        blur_passes=2
      }

      animations {
        enabled=1
        animation=windows,1,4,default,slide
        animation=borders,1,5,default
        animation=fadein,1,7,default
        animation=workspaces,1,2,default,fadein
      }

      dwindle {
        force_split=2
        preserve_split=1
      }

      input {
        kb_layout=br
      }

      # Startup
      exec=dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY
      exec-once=swaylock -i ${config.wallpaper}
      exec-once=waybar
      exec=swaybg -i ${config.wallpaper}
      exec-once=mako
      exec-once=swayidle -w
      exec-once=systemctl --user start hyprland-session.target

      # Program bindings
      bind=SUPER,Return,exec,${terminal.cmd}
      bind=SUPER,w,exec,${notifier.dismiss-cmd}
      bind=SUPER,v,exec,${editor.cmd}
      bind=SUPER,m,exec,${mail.cmd}
      bind=SUPER,b,exec,${browser.cmd}

      bind=SUPER,x,exec,${menu.drun-cmd}
      bind=SUPER,d,exec,${menu.run-cmd}
      bind=,Scroll_Lock,exec,${menu.password-cmd} # fn+k
      bind=,XF86Calculator,exec,${menu.password-cmd} # fn+f12

      # Lock screen
      bind=,XF86Launch5,exec,swaylock -S
      bind=,XF86Launch4,exec,swaylock -S

      # Screenshots
      bind=,Print,exec,grimshot --notify copy output
      bind=SHIFT,Print,exec,grimshot --notify copy active
      bind=CONTROL,Print,exec,grimshot --notify copy screen
      bind=ALT,Print,exec,grimshot --notify copy area
      bind=SUPERSHIFT,S,exec,grimshot --notify copy area # fn+print on pleione
      bind=SUPER,Print,exec,grimshot --notify copy window

      # Keyboard controls (brightness, media, sound, etc)
      bind=,XF86MonBrightnessUp,exec,light -A 10
      bind=,XF86MonBrightnessDown,exec,light -U 10

      bind=,XF86AudioNext,exec,playerctl next
      bind=,XF86AudioPrev,exec,playerctl previous
      bind=,XF86AudioPlay,exec,playerctl play-pause
      bind=,XF86AudioStop,exec,playerctl stop

      bind=,XF86AudioRaiseVolume,exec,pactl set-sink-volume @DEFAULT_SINK@ +5%
      bind=,XF86AudioLowerVolume,exec,pactl set-sink-volume @DEFAULT_SINK@ -5%
      bind=,XF86AudioMute,exec,pactl set-sink-mute @DEFAULT_SINK@ toggle

      bind=SHIFT,XF86AudioMute,exec,pactl set-source-mute @DEFAULT_SOURCE@ toggle
      bind=,XF86AudioMicMute,exec,pactl set-source-mute @DEFAULT_SOURCE@ toggle


      # Window manager controls
      bind=SUPERSHIFT,Q,killactive
      bind=SUPERSHIFT,E,exit

      bind=SUPER,s,togglesplit
      bind=SUPER,f,fullscreen,0
      bind=SUPERSHIFT,space,togglefloating

      bind=SUPER,minus,splitratio,-0.25
      bind=SUPERSHIFT,underscore,splitratio,-0.5
      bind=SUPERCONTROL,minus,splitratio,-0.3333333

      bind=SUPER,equal,splitratio,0.25
      bind=SUPERSHIFT,plus,splitratio,0.5
      bind=SUPERCONTROL,equal,splitratio,0.3333333

      bind=SUPER,left,movefocus,l
      bind=SUPER,right,movefocus,r
      bind=SUPER,up,movefocus,u
      bind=SUPER,down,movefocus,d
      bind=SUPER,h,movefocus,l
      bind=SUPER,l,movefocus,r
      bind=SUPER,k,movefocus,u
      bind=SUPER,j,movefocus,d

      bind=SUPERSHIFT,left,movewindow,l
      bind=SUPERSHIFT,right,movewindow,r
      bind=SUPERSHIFT,up,movewindow,u
      bind=SUPERSHIFT,down,movewindow,d
      bind=SUPERSHIFT,h,movewindow,l
      bind=SUPERSHIFT,l,movewindow,r
      bind=SUPERSHIFT,k,movewindow,u
      bind=SUPERSHIFT,j,movewindow,d

      bind=SUPERALT,left,movecurrentworkspacetomonitor,l
      bind=SUPERALT,right,movecurrentworkspacetomonitor,r
      bind=SUPERALT,up,movecurrentworkspacetomonitor,u
      bind=SUPERALT,down,movecurrentworkspacetomonitor,d
      bind=SUPERALT,h,movecurrentworkspacetomonitor,l
      bind=SUPERALT,l,movecurrentworkspacetomonitor,r
      bind=SUPERALT,k,movecurrentworkspacetomonitor,u
      bind=SUPERALT,j,movecurrentworkspacetomonitor,d

      bind=SUPER,u,togglespecialworkspace
      bind=SUPERSHIFT,u,movetoworkspace,special

      bind=SUPER,1,workspace,1
      bind=SUPER,2,workspace,2
      bind=SUPER,3,workspace,3
      bind=SUPER,4,workspace,4
      bind=SUPER,5,workspace,5
      bind=SUPER,6,workspace,6
      bind=SUPER,7,workspace,7
      bind=SUPER,8,workspace,8
      bind=SUPER,9,workspace,9
      bind=SUPER,0,workspace,10

      bind=SUPERSHIFT,exclam,movetoworkspace,1
      bind=SUPERSHIFT,at,movetoworkspace,2
      bind=SUPERSHIFT,numbersign,movetoworkspace,3
      bind=SUPERSHIFT,dollar,movetoworkspace,4
      bind=SUPERSHIFT,percent,movetoworkspace,5
      bind=SUPERSHIFT,asciicircum,movetoworkspace,6
      bind=SUPERSHIFT,ampersand,movetoworkspace,7
      bind=SUPERSHIFT,asterisk,movetoworkspace,8
      bind=SUPERSHIFT,parenleft,movetoworkspace,9
      bind=SUPERSHIFT,parenright,movetoworkspace,10
    '';

  # Start automatically on tty1
  programs.zsh.loginExtra = lib.mkBefore ''
    if [[ "$(tty)" == /dev/tty1 ]]; then
      exec Hyprland &> hyprland.log
    fi
  '';
  programs.fish.loginShellInit = lib.mkBefore ''
    if test (tty) = /dev/tty1
      exec Hyprland &> hyprland.log
    end
  '';
  programs.bash.profileExtra = lib.mkBefore ''
    if [[ "$(tty)" == /dev/tty1 ]]; then
      exec Hyprland &> hyprland.log
    fi
  '';

  systemd.user.targets.hyprland-session = {
    Unit = {
      Description = "hyprland compositor session";
      Documentation = [ "man:systemd.special(7)" ];
      BindsTo = [ "graphical-session.target" ];
      Wants = [ "graphical-session-pre.target" ];
      After = [ "graphical-session-pre.target" ];
    };
  };

  systemd.user.targets.tray = {
    Unit = {
      Description = "Home Manager System Tray";
      Requires = [ "graphical-session-pre.target" ];
    };
  };
}
