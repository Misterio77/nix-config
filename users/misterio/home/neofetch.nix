{ pkgs, ... }:

let glxinfo = "${pkgs.glxinfo}/bin/glxinfo";
in {
  home.packages = with pkgs; [ neofetch ];
  xdg.configFile."neofetch/config.conf".text = ''
    print_info() {
        # info title
        # info underline
        info "OS" distro
        info "Kernel" kernel
        info "Uptime" uptime
        info "Packages" packages
        info "Shell" shell
        info "WM" wm
        info "Term" term
        # info "CPU" cpu
        # prin "GPU" "$(${glxinfo} | grep Device | cut -d ':' -f2 | cut -d '(' -f1)"
        # info "Memory" memory
        # info "Disk" disk
        # info cols
    }
    title_fqdn="off"
    kernel_shorthand="on"
    distro_shorthand="off"
    os_arch="off"
    uptime_shorthand="on"
    memory_percent="off"
    package_managers="on"
    shell_path="off"
    shell_version="on"
    speed_type="scaling_max_freq"
    speed_shorthand="on"
    cpu_brand="on"
    cpu_speed="on"
    cpu_cores="off"
    cpu_temp="off"
    gpu_brand="on"
    gpu_type="all"
    refresh_rate="on"
    gtk_shorthand="on"
    gtk2="on"
    gtk3="on"
    public_ip_host="http://ident.me"
    public_ip_timeout=2
    de_version="off"
    disk_show=('/' '/nix' '/backups')
    disk_subtitle="mount"
    disk_percent="on"
    music_player="auto"
    song_format="%artist% - %album% - %title%"
    song_shorthand="on"
    mpc_args=()
    colors=(distro)
    bold="on"
    underline_enabled="on"
    underline_char="-"
    separator=":"
    block_range=(0 15)
    color_blocks="on"
    block_width=3
    block_height=1
    col_offset="auto"
    bar_char_elapsed="-"
    bar_char_total="="
    bar_border="on"
    bar_length=15
    bar_color_elapsed="distro"
    bar_color_total="distro"
    cpu_display="off"
    memory_display="off"
    memory_unit="gib"
    battery_display="off"
    disk_display="on"
    image_backend="ascii"
    image_source="auto"
    ascii_distro="nixos_small"
    #ascii_distro="auto"
    ascii_colors=(distro)
    ascii_bold="on"
    image_loop="off"
    crop_mode="normal"
    crop_offset="center"
    image_size="auto"
    gap=3
    yoffset=0
    xoffset=0
    background_color=
    stdout="off"
  '';
}
