{ inputs, lib, config, pkgs, hostname, ... }: {
  imports = [
    ../common
    ../common/wayland-wm
    inputs.hyprland.homeManagerModules.default
  ];

  wayland.windowManager.hyprland =
    let
      inherit (config.colorscheme) colors;
      inherit (config.home.preferredApps)
        menu browser editor mail notifier terminal;

      grimblast = "${pkgs.grimblast}/bin/grimblast";
      light = "${pkgs.light}/bin/light";
      mako = "${pkgs.mako}/bin/mako";
      pactl = "${pkgs.pulseaudio}/bin/pactl";
      playerctl = "${pkgs.playerctl}/bin/playerctl";
      playerctld = "${pkgs.playerctl}/bin/playerctld";
      swaybg = "${pkgs.swaybg}/bin/swaybg";
      swayidle = "${pkgs.swayidle}/bin/swayidle";
      swaylock = "${pkgs.swaylock-effects}/bin/swaylock";
      systemctl = "${pkgs.systemd}/bin/systemctl";
    in
    {
      enable = true;
      package = pkgs.hyprland;
      extraConfig =
        (lib.optionalString (hostname == "atlas") ''
          monitor=DP-3,1920x1080@60,0x0,1
          workspace=DP-3,3
          monitor=DP-1,2560x1080@75,1920x0,1
          workspace=DP-1,1
          monitor=DP-2,1920x1080@60,4480x0,1
          workspace=DP-2,2
        '') +
        (lib.optionalString (hostname == "pleione") ''
          monitor=eDP-1,1920x1080@60,0x0,1
          workspace=eDP-1,1
        '') +
        ''
          general {
            main_mod=SUPER
            gaps_in=15
            gaps_out=20
            border_size=2.7
            col.active_border=0xff${colors.base0C}
            col.inactive_border=0xff${colors.base02}
            cursor_inactive_timeout=4
          }

          decoration {
            active_opacity=0.93
            inactive_opacity=0.80
            fullscreen_opacity=1.0
            rounding=5
            blur=true
            blur_size=3
            blur_passes=3
            drop_shadow=true
            shadow_range=12
            shadow_offset=3 3
            col.shadow=0x44000000
            col.shadow_inactive=0x66000000
          }

          animations {
            enabled=true
            animation=windows,1,4,default,slide
            animation=border,1,5,default
            animation=fade,1,7,default
            animation=workspaces,1,2,default
          }

          dwindle {
            force_split=2
            preserve_split=true
            col.group_border_active=0xff${colors.base0B}
            col.group_border=0xff${colors.base04}
          }

          input {
            kb_layout=br
          }
          input:touchpad {
            disable_while_typing=false
          }

          # Startup
          exec-once=${swaylock} -i ${config.wallpaper}
          exec-once=waybar
          exec=${swaybg} -i ${config.wallpaper} --mode fill
          exec-once=${mako}
          exec-once=${swayidle} -w

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
          bind=SUPER,c,exec,${terminal.cmd-spawn "${pkgs.bc}/bin/bc"}

          # Toggle waybar
          bind=,XF86Tools,exec,${pkgs.procps}/bin/pkill -USR1 waybar # profile button

          # Lock screen
          bind=,XF86Launch5,exec,${swaylock} -S
          bind=,XF86Launch4,exec,${swaylock} -S

          # Screenshots
          bind=,Print,exec,${grimblast} --notify copy output
          bind=SHIFT,Print,exec,${grimblast} --notify copy active
          bind=CONTROL,Print,exec,${grimblast} --notify copy screen
          bind=SUPER,Print,exec,${grimblast} --notify copy window
          bind=ALT,Print,exec,${grimblast} --notify copy area

          # Keyboard controls (brightness, media, sound, etc)
          bind=,XF86MonBrightnessUp,exec,${light} -A 10
          bind=,XF86MonBrightnessDown,exec,${light} -U 10

          bind=,XF86AudioNext,exec,${playerctl} next
          bind=,XF86AudioPrev,exec,${playerctl} previous
          bind=,XF86AudioPlay,exec,${playerctl} play-pause
          bind=,XF86AudioStop,exec,${playerctl} stop
          bind=ALT,XF86AudioNext,exec,${playerctld} shift
          bind=ALT,XF86AudioPrev,exec,${playerctld} unshift
          bind=ALT,XF86AudioPlay,exec,${systemctl} --user restart playerctld
          bind=SUPER,XF86AudioPlay,exec,${terminal.cmd-spawn "${pkgs.lyrics}/bin/lyrics"}

          bind=,XF86AudioRaiseVolume,exec,${pactl} set-sink-volume @DEFAULT_SINK@ +5%
          bind=,XF86AudioLowerVolume,exec,${pactl} set-sink-volume @DEFAULT_SINK@ -5%
          bind=,XF86AudioMute,exec,${pactl} set-sink-mute @DEFAULT_SINK@ toggle

          bind=SHIFT,XF86AudioMute,exec,${pactl} set-source-mute @DEFAULT_SOURCE@ toggle
          bind=,XF86AudioMicMute,exec,${pactl} set-source-mute @DEFAULT_SOURCE@ toggle


          # Window manager controls
          bind=SUPERSHIFT,q,killactive
          bind=SUPERSHIFT,e,exit

          bind=SUPER,s,togglesplit
          bind=SUPER,f,fullscreen,1
          bind=SUPERSHIFT,f,fullscreen,0
          bind=SUPERSHIFT,space,togglefloating

          bind=SUPER,minus,splitratio,-0.25
          bind=SUPERSHIFT,minus,splitratio,-0.3333333

          bind=SUPER,equal,splitratio,0.25
          bind=SUPERSHIFT,equal,splitratio,0.3333333

          bind=SUPER,g,togglegroup
          bind=SUPER,apostrophe,changegroupactive,f
          bind=SUPERSHIFT,apostrophe,changegroupactive,b

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

          bind=SUPERCONTROL,left,focusmonitor,l
          bind=SUPERCONTROL,right,focusmonitor,r
          bind=SUPERCONTROL,up,focusmonitor,u
          bind=SUPERCONTROL,down,focusmonitor,d
          bind=SUPERCONTROL,h,focusmonitor,l
          bind=SUPERCONTROL,l,focusmonitor,r
          bind=SUPERCONTROL,k,focusmonitor,u
          bind=SUPERCONTROL,j,focusmonitor,d

          bind=SUPERCONTROL,1,focusmonitor,DP-1
          bind=SUPERCONTROL,2,focusmonitor,DP-2
          bind=SUPERCONTROL,3,focusmonitor,DP-3

          bind=SUPERCONTROLSHIFT,left,movewindow,mon:l
          bind=SUPERCONTROLSHIFT,right,movewindow,mon:r
          bind=SUPERCONTROLSHIFT,up,movewindow,mon:u
          bind=SUPERCONTROLSHIFT,down,movewindow,mon:d
          bind=SUPERCONTROLSHIFT,h,movewindow,mon:l
          bind=SUPERCONTROLSHIFT,l,movewindow,mon:r
          bind=SUPERCONTROLSHIFT,k,movewindow,mon:u
          bind=SUPERCONTROLSHIFT,j,movewindow,mon:d

          bind=SUPERCONTROLSHIFT,1,movewindow,mon:DP-1
          bind=SUPERCONTROLSHIFT,2,movewindow,mon:DP-2
          bind=SUPERCONTROLSHIFT,3,movewindow,mon:DP-3

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

          bind=SUPERSHIFT,1,movetoworkspacesilent,1
          bind=SUPERSHIFT,2,movetoworkspacesilent,2
          bind=SUPERSHIFT,3,movetoworkspacesilent,3
          bind=SUPERSHIFT,4,movetoworkspacesilent,4
          bind=SUPERSHIFT,5,movetoworkspacesilent,5
          bind=SUPERSHIFT,6,movetoworkspacesilent,6
          bind=SUPERSHIFT,7,movetoworkspacesilent,7
          bind=SUPERSHIFT,8,movetoworkspacesilent,8
          bind=SUPERSHIFT,9,movetoworkspacesilent,9
          bind=SUPERSHIFT,0,movetoworkspacesilent,10

          blurls=waybar
        '';
    };
}
