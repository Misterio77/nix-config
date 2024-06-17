{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) hashString toJSON;
  rendersvg = pkgs.runCommand "rendersvg" {} ''
    mkdir -p $out/bin
    ln -s ${pkgs.resvg}/bin/resvg $out/bin/rendersvg
  '';
  materiaTheme = name: colors:
    pkgs.stdenv.mkDerivation {
      name = "generated-gtk-theme";
      src = pkgs.fetchFromGitHub {
        owner = "nana-4";
        repo = "materia-theme";
        rev = "76cac96ca7fe45dc9e5b9822b0fbb5f4cad47984";
        sha256 = "sha256-0eCAfm/MWXv6BbCl2vbVbvgv8DiUH09TAUhoKq7Ow0k=";
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
      phases = ["unpackPhase" "installPhase"];
      installPhase = ''
        HOME=/build
        chmod 777 -R .
        patchShebangs .
        mkdir -p $out/share/themes
        mkdir bin
        sed -e 's/handle-horz-.*//' -e 's/handle-vert-.*//' -i ./src/gtk-2.0/assets.txt

        cat > /build/gtk-colors << EOF
          BTN_BG=${colors.primary_container}
          BTN_FG=${colors.on_primary_container}
          BG=${colors.surface}
          FG=${colors.on_surface}
          HDR_BTN_BG=${colors.secondary_container}
          HDR_BTN_FG=${colors.on_secondary_container}
          ACCENT_BG=${colors.primary}
          ACCENT_FG=${colors.on_primary}
          HDR_BG=${colors.surface_bright}
          HDR_FG=${colors.on_surface}
          MATERIA_SURFACE=${colors.surface_bright}
          MATERIA_VIEW=${colors.surface_dim}
          MENU_BG=${colors.surface_container}
          MENU_FG=${colors.on_surface}
          SEL_BG=${colors.primary_fixed_dim}
          SEL_FG=${colors.on_primary}
          TXT_BG=${colors.primary_container}
          TXT_FG=${colors.on_primary_container}
          WM_BORDER_FOCUS=${colors.outline}
          WM_BORDER_UNFOCUS=${colors.outline_variant}
          UNITY_DEFAULT_LAUNCHER_STYLE=False
          NAME=${name}
          MATERIA_STYLE_COMPACT=True
        EOF

        echo "Changing colours:"
        ./change_color.sh -o ${name} /build/gtk-colors -i False -t "$out/share/themes"
        chmod 555 -R .
      '';
    };
in rec {
  gtk = {
    enable = true;
    font = {
      name = config.fontProfiles.regular.family;
      size = 12;
    };
    theme = let
      inherit (config.colorscheme) mode colors;
      name = "generated-${hashString "md5" (toJSON colors)}-${mode}";
    in {
      inherit name;
      package = materiaTheme name (
        lib.mapAttrs (_: v: lib.removePrefix "#" v) colors
      );
    };
    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
    };
  };

  services.xsettingsd = {
    enable = true;
    settings = {
      "Net/ThemeName" = "${gtk.theme.name}";
      "Net/IconThemeName" = "${gtk.iconTheme.name}";
    };
  };

  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];
}
