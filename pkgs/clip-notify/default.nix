{
  lib,
  writeShellApplication,
  file,
  coreutils,
  libnotify,
  wl-clipboard,
}:
(writeShellApplication {
  name = "clip-notify";
  runtimeInputs = [file coreutils libnotify wl-clipboard];
  text = builtins.readFile ./clip-notify.sh;
})
// {
  meta = with lib; {
    licenses = licenses.mit;
    platforms = platforms.all;
  };
}
