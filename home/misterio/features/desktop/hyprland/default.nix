{ inputs, lib, config, pkgs, ... }: {
  imports = [
    ../common
    ../common/wayland-wm
    inputs.hyprland.homeManagerModules.default
  ];

  programs = {
    fish.loginShellInit = ''
      if test (tty) = "/dev/tty1"
        exec Hyprland
      end
    '';
    zsh.loginExtra = ''
      if [ "$(tty)" = "/dev/tty1" ]; then
        exec Hyprland
      fi
    '';
    zsh.profileExtra = ''
      if [ "$(tty)" = "/dev/tty1" ]; then
        exec Hyprland
      fi
    '';
  };

  wayland.windowManager.hyprland =
    let
      inherit (config.colorscheme) colors;

      grimblast = "${inputs.hyprwm-contrib.packages.${pkgs.system}.grimblast}/bin/grimblast";

      light = "${pkgs.light}/bin/light";
      mako = "${pkgs.mako}/bin/mako";
      makoctl = "${pkgs.mako}/bin/makoctl";
      neomutt = "${pkgs.neomutt}/bin/neomutt";
      pactl = "${pkgs.pulseaudio}/bin/pactl";
      pass-wofi = "${pkgs.pass-wofi}/bin/pass-wofi";
      playerctl = "${pkgs.playerctl}/bin/playerctl";
      playerctld = "${pkgs.playerctl}/bin/playerctld";
      qutebrowser = "${pkgs.qutebrowser}/bin/qutebrowser";
      swaybg = "${pkgs.swaybg}/bin/swaybg";
      swayidle = "${pkgs.swayidle}/bin/swayidle";
      swaylock = "${pkgs.swaylock-effects}/bin/swaylock";
      systemctl = "${pkgs.systemd}/bin/systemctl";
      wofi = "${pkgs.wofi}/bin/wofi";

      terminal = "${pkgs.kitty}/bin/kitty";
      terminal-spawn = cmd: "${terminal} $SHELL -i -c ${cmd}";

      nvim = lib.optionalString
        config.programs.neovim.enable "${config.programs.neovim.finalPackage}/bin/nvim";
      emacs = lib.optionalString
        config.programs.emacs.enable "${config.programs.emacs.finalPackage}/bin/emacsclient -c";
    in
    {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.system}.default;
      extraConfig = (builtins.concatStringsSep "\n"
        (lib.forEach config.monitors
          (m: ''
            monitor=${m.name},${toString m.width}x${toString m.height}@${toString m.refreshRate},${toString m.x}x${toString m.y},${if m.enabled then "1" else "0"}
            ${lib.optionalString (m.workspace != null)"workspace=${m.name},${m.workspace}"}
          '')
        )
      ) +
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
          active_opacity=0.88
          inactive_opacity=0.68
          fullscreen_opacity=1.0
          rounding=5
          blur=true
          blur_size=6
          blur_passes=3
          blur_new_optimizations=true
          blur_ignore_opacity=true
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
          col.group_border_active=0xff${colors.base0B}
          col.group_border=0xff${colors.base04}
          split_width_multiplier=1.35
        }

        misc {
          no_vfr=false
        }

        input {
          kb_layout=br
          touchpad {
            disable_while_typing=false
          }
        }

        # Startup
        exec-once=waybar
        exec=${swaybg} -i ${config.wallpaper} --mode fill
        exec-once=${mako}
        exec-once=${swayidle} -w

        # Mouse binding
        bindm=SUPER,mouse:272,movewindow
        bindm=SUPER,mouse:273,resizewindow

        # Program bindings
        bind=SUPER,Return,exec,${terminal}
        bind=SUPER,w,exec,${makoctl} dismiss
        bind=SUPER,e,exec,${emacs}
        bind=SUPER,v,exec,${terminal-spawn nvim}
        bind=SUPER,m,exec,${terminal-spawn neomutt}
        bind=SUPER,b,exec,${qutebrowser}

        bind=SUPER,x,exec,${wofi} -S drun -x 10 -y 10 -W 25% -H 60%
        bind=SUPER,d,exec,${wofi} -S run
        bind=,Scroll_Lock,exec,${pass-wofi} # fn+k
        bind=,XF86Calculator,exec,${pass-wofi} # fn+f12

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
        bind=SUPER,XF86AudioPlay,exec,${terminal-spawn "${pkgs.lyrics}/bin/lyrics"}

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

        bind=SUPER,1,workspace,01
        bind=SUPER,2,workspace,02
        bind=SUPER,3,workspace,03
        bind=SUPER,4,workspace,04
        bind=SUPER,5,workspace,05
        bind=SUPER,6,workspace,06
        bind=SUPER,7,workspace,07
        bind=SUPER,8,workspace,08
        bind=SUPER,9,workspace,09
        bind=SUPER,0,workspace,10
        bind=SUPER,f1,workspace,11
        bind=SUPER,f2,workspace,12
        bind=SUPER,f3,workspace,13
        bind=SUPER,f4,workspace,14
        bind=SUPER,f5,workspace,15
        bind=SUPER,f6,workspace,16
        bind=SUPER,f7,workspace,17
        bind=SUPER,f8,workspace,18
        bind=SUPER,f9,workspace,19
        bind=SUPER,f10,workspace,20
        bind=SUPER,f11,workspace,21
        bind=SUPER,f12,workspace,22

        bind=SUPERSHIFT,1,movetoworkspacesilent,01
        bind=SUPERSHIFT,2,movetoworkspacesilent,02
        bind=SUPERSHIFT,3,movetoworkspacesilent,03
        bind=SUPERSHIFT,4,movetoworkspacesilent,04
        bind=SUPERSHIFT,5,movetoworkspacesilent,05
        bind=SUPERSHIFT,6,movetoworkspacesilent,06
        bind=SUPERSHIFT,7,movetoworkspacesilent,07
        bind=SUPERSHIFT,8,movetoworkspacesilent,08
        bind=SUPERSHIFT,9,movetoworkspacesilent,09
        bind=SUPERSHIFT,0,movetoworkspacesilent,10
        bind=SUPERSHIFT,f1,movetoworkspacesilent,11
        bind=SUPERSHIFT,f2,movetoworkspacesilent,12
        bind=SUPERSHIFT,f3,movetoworkspacesilent,13
        bind=SUPERSHIFT,f4,movetoworkspacesilent,14
        bind=SUPERSHIFT,f5,movetoworkspacesilent,15
        bind=SUPERSHIFT,f6,movetoworkspacesilent,16
        bind=SUPERSHIFT,f7,movetoworkspacesilent,17
        bind=SUPERSHIFT,f8,movetoworkspacesilent,18
        bind=SUPERSHIFT,f9,movetoworkspacesilent,19
        bind=SUPERSHIFT,f10,movetoworkspacesilent,20
        bind=SUPERSHIFT,f11,movetoworkspacesilent,21
        bind=SUPERSHIFT,f12,movetoworkspacesilent,22

        blurls=waybar
      '';
    };
}
