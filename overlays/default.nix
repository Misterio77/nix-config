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
    };

  # Modifies existing packages
  modifications = final: prev: {
    vimPlugins =
      prev.vimPlugins
      // {
        vim-numbertoggle = addPatches prev.vimPlugins.vim-numbertoggle [
          ./vim-numbertoggle-command-mode.patch
        ];
      };

    qutebrowser = prev.qutebrowser.overrideAttrs (oldAttrs: {
      preFixup =
        oldAttrs.preFixup
        +
        # Force x11, as live-refreshing colorscheme based on portal is not working on wayland platform atm
        # This is fixed by https://codereview.qt-project.org/c/qt/qtbase/+/547252
        ''
          makeWrapperArgs+=(
            --set QT_QPA_PLATFORM xcb
          )
        ''
        +
        # Fix for https://github.com/NixOS/nixpkgs/issues/168484
        (let
          schemaPath = package: "${package}/share/gsettings-schemas/${package.name}";
        in ''
          makeWrapperArgs+=(
            --prefix XDG_DATA_DIRS : ${schemaPath final.gsettings-desktop-schemas}
            --prefix XDG_DATA_DIRS : ${schemaPath final.gtk3}
          )
        '');
      patches =
        (oldAttrs.patches or [])
        ++ [
          # Repaint tabs when colorscheme changes
          ./qutebrowser-refresh-tab-colorscheme.patch
          # Reload on SIGHUP
          # https://github.com/qutebrowser/qutebrowser/pull/8110
          (final.fetchurl {
            url = "https://patch-diff.githubusercontent.com/raw/qutebrowser/qutebrowser/pull/8110.patch";
            hash = "sha256-W30aGOAy8F/PlfUK2fgJQEcVu5QHcWSus6RKIlvVT1g=";
          })
        ];
    });

    qemu = prev.qemu.overrideAttrs (oldAttrs: rec {
      version = "8.2.3";
      src = final.fetchurl {
        url = "https://download.qemu.org/qemu-${version}.tar.xz";
        hash = "sha256-d1sRjKpjZiCnr0saFWRFoaKA9a1Ss7y7F/jilkhB21g=";
      };
    });


    # TODO: https://github.com/NixOS/nixpkgs/pull/304154
    pam_rssh = prev.pam_rssh.overrideAttrs (oldAttrs: {
      nativeCheckInputs = [(final.openssh.override {dsaKeysSupport = true;})];
    });
  };
}
