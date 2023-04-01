{ pkgs, lib, config, ... }:
let
  enabledMonitors = lib.filter (m: m.enabled) config.monitors;
  # A nice VNC script for remotes running hyprland
  vncsh = pkgs.writeShellScriptBin "vnc.sh" ''
    ssh $1 bash <<'EOF'
        pgrep "wayvnc" && exit
        export HYPRLAND_INSTANCE_SIGNATURE="$(ls /tmp/hypr/ -lt | head -2 | tail -1 | rev | cut -d ' ' -f1 | rev)"
        export WAYLAND_DISPLAY="wayland-1"
        ip="$(ip addr show dev tailscale0 | grep 'inet ' | xargs | cut -d ' ' -f2 | cut -d '/' -f1)"
        xpos="$(hyprctl monitors -j | jq -r 'sort_by(.x)[-1] | .x + .width')"

        ${lib.concatLines (lib.forEach enabledMonitors (m: ''
          hyprctl output create headless
          monitor="$(hyprctl monitors -j | jq -r 'map(.name)[-1]')"
          hyprctl keyword monitor $monitor,${toString m.width}x${toString m.height}@${toString m.refreshRate},$(($xpos + ${toString m.x}))x${toString m.y},1
          screen -d -m wayvnc -k br -S /tmp/vnc-${m.workspace} -f 60 -o $monitor $ip 590${m.workspace}
          sudo iptables -I INPUT -j ACCEPT -p tcp --dport 590${m.workspace}
        ''))}
    EOF

    ${lib.concatLines (lib.forEach enabledMonitors (m: ''
      vncviewer $1::590${m.workspace} &
    ''))}

    wait
  '';
in
{
  home.packages = with pkgs; [
    vncsh
    wayvnc
    tigervnc
  ];
}
