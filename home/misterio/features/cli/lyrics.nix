{pkgs, ...}: {
  home.packages = [pkgs.lyrics];
  xdg.configFile."lyrics-in-terminal/lyrics.cfg".text =
    /*
    ini
    */
    ''
      [OPTIONS]
      alignment=left
      source=google
      interval=1500
      autoswitch=on
      player=
      mpd_host=
      mpd_port=
      mpd_pass=

      [BINDINGS]
      up=k
      down=j
      left=i
      center=o
      right=p
      step-up=arrow_up
      step-down=arrow_down
      step-size=5
      google=R
      azLyrics=r
      autoswitchtoggle=a
      delete=d
      edit=e
      help=h
      quit=q
    '';
}
