{
  outputs,
  inputs,
}: let
  addPatches = pkg: patches:
    pkg.overrideAttrs (oldAttrs: {
      patches = (oldAttrs.patches or []) ++ patches;
    });
in {
  # For every flake input, aliases 'pkgs.inputs.${flake}' to
  # 'inputs.${flake}.packages.${pkgs.system}' or
  # 'inputs.${flake}.legacyPackages.${pkgs.system}'
  flake-inputs = final: _: {
    inputs =
      builtins.mapAttrs (
        _: flake: let
          legacyPackages = (flake.legacyPackages or {}).${final.system} or {};
          packages = (flake.packages or {}).${final.system} or {};
        in
          if legacyPackages != {}
          then legacyPackages
          else packages
      )
      inputs;
  };

  # Adds pkgs.stable == inputs.nixpkgs-stable.legacyPackages.${pkgs.system}
  stable = final: _: {
    stable = inputs.nixpkgs-stable.legacyPackages.${final.system};
  };

  # Adds my custom packages
  additions = final: prev:
    import ../pkgs {pkgs = final;}
    // {
      formats = (prev.formats or {}) // import ../pkgs/formats {pkgs = final;};
      vimPlugins = (prev.vimPlugins or {}) // import ../pkgs/vim-plugins {pkgs = final;};
    };

  # Modifies existing packages
  modifications = final: prev: {
    vimPlugins =
      prev.vimPlugins
      // {
        vim-numbertoggle = addPatches prev.vimPlugins.vim-numbertoggle [
          ./vim-numbertoggle-command-mode.patch
        ];
        ltex_extra-nvim = addPatches prev.vimPlugins.ltex_extra-nvim [
          ./ltex-change-lang-command.diff
        ];
      };

    # https://github.com/NixOS/nixpkgs/pull/303472
    gns3-server = prev.gns3-server.overrideAttrs (_: {
      makeWrapperArgs = [ "--suffix PATH : ${final.lib.makeBinPath [ final.util-linux ]}" ];
    });

    # https://github.com/mdellweg/pass_secret_service/pull/37
    pass-secret-service = addPatches prev.pass-secret-service [./pass-secret-service-native.diff];

    qutebrowser = prev.qutebrowser.overrideAttrs (oldAttrs: {
      preFixup =
        oldAttrs.preFixup
        +
        # Fix for https://github.com/NixOS/nixpkgs/issues/168484
        (let
          schemaPath = package: "${package}/share/gsettings-schemas/${package.name}";
        in ''
          makeWrapperArgs+=(
            --prefix GIO_EXTRA_MODULES : "${final.lib.getLib final.dconf}/lib/gio/modules"
            --prefix XDG_DATA_DIRS : ${schemaPath final.gsettings-desktop-schemas}
            --prefix XDG_DATA_DIRS : ${schemaPath final.gtk3}
          )
        '');
      patches =
        (oldAttrs.patches or [])
        ++ [
          # Repaint tabs when colorscheme changes
          ./qutebrowser-refresh-tab-colorscheme.patch
        ];
    });

    wl-clipboard = addPatches prev.wl-clipboard [./wl-clipboard-secrets.diff];

    pass = addPatches prev.pass [./pass-wlclipboard-secret.diff];

    hydra_unstable = prev.hydra_unstable.overrideAttrs (_: {
      patches = [./hydra-restrict-eval.diff];
    });
  };
}
