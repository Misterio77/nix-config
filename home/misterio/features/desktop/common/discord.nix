{ config, pkgs, ... }:

let
  c = config.colorscheme.palette;
in
{
  home.packages = with pkgs; [ vesktop ];

  home.persistence = {
    "/persist/home/misterio".directories = [ ".config/vesktop" ];
  };

  xdg.configFile."vesktop/themes/base16.css".text = /* css */
    ''
      @import url("https://slowstab.github.io/dracula/BetterDiscord/source.css");
      @import url("https://mulverinex.github.io/legacy-settings-icons/dist-native.css");
      .theme-dark, .theme-light, :root {
        --text-default: #${c.base05};
        --header-primary: #${c.base05};
        --header-secondary: #${c.base04};
        --channeltextarea-background: #${c.base02};
        --interactive-normal: #${c.base04};
        --interactive-active: #${c.base05};

        --dracula-primary: #${c.base00};
        --dracula-secondary: #${c.base01};
        --dracula-secondary-alpha: #${c.base01}ee;
        --dracula-tertiary: #${c.base03};
        --dracula-tertiary-alpha: #${c.base03}aa;
        --dracula-primary-light: #${c.base02};

        --dracula-accent: #${c.base09};
        --dracula-accent-alpha: #${c.base09}66;
        --dracula-accent-alpha-alt: #${c.base09}88;
        --dracula-accent-alpha-alt2: #${c.base09}aa;
        --dracula-accent-dark: #${c.base0E};
        --dracula-accent-light: #${c.base08};
      }

      html.theme-light #app-mount::after {
        content: none;
      }
    '';
}
