{ config, pkgs, ... }:

let
  rendersvg = pkgs.runCommandNoCC "rendersvg" { } ''
    mkdir -p $out/bin
    ln -s ${pkgs.resvg}/bin/resvg $out/bin/rendersvg
  '';
  generateMateriaGtkTheme = scheme: pkgs.stdenv.mkDerivation rec {
    name = "generated-gtk-theme";
    src = pkgs.fetchFromGitHub {
      owner = "nana-4";
      repo = "materia-theme";
      rev = "76cac96ca7fe45dc9e5b9822b0fbb5f4cad47984";
      sha256 = "sha256-0eCAfm/MWXv6BbCl2vbVbvgv8DiUH09TAUhoKq7Ow0k=";
      fetchSubmodules = true;
    };
    buildInputs = with pkgs; [
      sassc
      bc
      which
      rendersvg
      meson
      ninja
      nodePackages.sass
      gtk4.dev
      optipng
    ];
    phases = [ "unpackPhase" "installPhase" ];
    installPhase = ''
      HOME=/build
      chmod 777 -R .
      patchShebangs .
      mkdir -p $out/share/themes
      mkdir bin
      sed -e 's/handle-horz-.*//' -e 's/handle-vert-.*//' -i ./src/gtk-2.0/assets.txt

      cat > /build/gtk-colors << EOF
        BTN_BG=${scheme.colors.base02}
        BTN_FG=${scheme.colors.base06}
        FG=${scheme.colors.base05}
        BG=${scheme.colors.base00}
        HDR_BTN_BG=${scheme.colors.base01}
        HDR_BTN_FG=${scheme.colors.base05}
        ACCENT_BG=${scheme.colors.base0B}
        ACCENT_FG=${scheme.colors.base00}
        HDR_FG=${scheme.colors.base05}
        HDR_BG=${scheme.colors.base02}
        MATERIA_SURFACE=${scheme.colors.base02}
        MATERIA_VIEW=${scheme.colors.base01}
        MENU_BG=${scheme.colors.base02}
        MENU_FG=${scheme.colors.base06}
        SEL_BG=${scheme.colors.base0D}
        SEL_FG=${scheme.colors.base0E}
        TXT_BG=${scheme.colors.base02}
        TXT_FG=${scheme.colors.base06}
        WM_BORDER_FOCUS=${scheme.colors.base05}
        WM_BORDER_UNFOCUS=${scheme.colors.base03}
        UNITY_DEFAULT_LAUNCHER_STYLE=False
        NAME=${scheme.slug}
        MATERIA_STYLE_COMPACT=True
      EOF

      echo "Changing colours:"
      ./change_color.sh -o ${scheme.slug} /build/gtk-colors -i False -t "$out/share/themes"
      chmod 555 -R .
    '';
  };
in rec {

  gtk = {
    enable = true;

    font = {
      name = "Fira Sans";
      size = 12;
    };

    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
    };

    theme = {
      name = "${config.colorscheme.slug}";
      package = generateMateriaGtkTheme config.colorscheme;
    };
  };
  services.xsettingsd = {
    enable = true;
    settings = {
      "Net/ThemeName" = "${gtk.theme.name}";
      "Net/IconThemeName" = "${gtk.iconTheme.name}";
    };
  };
}
