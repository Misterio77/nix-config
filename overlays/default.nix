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

  # Adds my custom packages
  additions = final: prev:
    import ../pkgs {pkgs = final;}
    // {
      formats = (prev.formats or {}) // import ../pkgs/formats {pkgs = final;};
      vimPlugins = (prev.vimPlugins or {}) // import ../pkgs/vim-plugins {pkgs = final;};
      roundcubePlugins = (prev.roundcubePlugins or {}) // import ../pkgs/roundcube-plugins {pkgs = final;};
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

    vdirsyncer = addPatches prev.vdirsyncer [./vdirsyncer-fixed-oauth-token.patch];

    # https://github.com/pimutils/todoman/pull/594
    todoman = addPatches prev.todoman [
      ./todoman-latest-main.patch
      ./todoman-subtasks.patch
      ./todoman-disable-uid-hostname-suffix.diff
    ];

    # https://github.com/ValveSoftware/gamescope/issues/1622
    gamescope = prev.gamescope.overrideAttrs (_: {
      NIX_CFLAGS_COMPILE = ["-fno-fast-math"];
    });

    # Force $XDG_CONFIG_DIR/hdos
    # Read credentials.properties
    hdos = prev.hdos.overrideAttrs (_: let
      inherit (final) lib openjdk11 libGL;
    in {
      installPhase = ''
        runHook preInstall
        makeWrapper ${lib.getExe openjdk11} $out/bin/hdos \
          --run "export XDG_CONFIG_DIR=\"\''${XDG_CONFIG_DIR:-\$HOME/.config}\"" \
          --run "export HDOS_DIR=\"\$XDG_CONFIG_DIR/hdos\"" \
          --run "export HOME=\"\$XDG_CONFIG_DIR\"" \
          --run "set -a" \
          --run "source \"\$HDOS_DIR/credentials.properties\" || true" \
          --run "set +a" \
          --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ libGL ]}" \
          --add-flags "-Dapp.user.home=\"\$HDOS_DIR\"" \
          --add-flags "-Duser.home=\"\$HDOS_DIR\"" \
          --add-flags "-jar $src"
        runHook postInstall
      '';
    });
  };
}
