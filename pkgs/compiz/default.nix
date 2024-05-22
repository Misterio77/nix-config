{
  stdenv,
  fetchurl,
  lib,
  cmake,
  pkg-config,
  makeWrapper,
  boost,
  cairo,
  fuse,
  glibmm,
  gnome,
  gtk3,
  intltool,
  libnotify,
  libstartup_notification,
  libwnck3,
  libxml2,
  libxslt,
  mesa_glu,
  pcre2,
  protobuf,
  python3Packages,
  gobject-introspection,
  xorg,
  xorgserver,
  wrapGAppsHook3,
  ...
}:
stdenv.mkDerivation (f: {
  pname = "compiz";
  version = "0.9.14.2";
  shortVersion = "${lib.versions.majorMinor f.version}.${lib.versions.patch f.version}";
  src = fetchurl {
    url = "https://launchpad.net/compiz/${f.shortVersion}/${f.version}/+download/compiz-${f.version}.tar.xz";
    hash = "sha256-z6Bh6TsDInX/nnBB9YKo9tWuJxz4qJ5rx049NjWZnTw=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    makeWrapper
    xorg.libXdmcp.dev
    pcre2.dev
    libxml2.dev
    wrapGAppsHook3
    python3Packages.cython
    python3Packages.setuptools
    python3Packages.wrapPython
  ];
  buildInputs = [
    boost
    cairo
    fuse
    glibmm
    gnome.metacity
    gobject-introspection
    gtk3
    intltool
    libnotify
    libstartup_notification
    libwnck3
    libxml2
    libxslt
    mesa_glu
    pcre2
    pcre2.dev
    protobuf
    xorg.libXcursor
    xorg.libXdmcp
    xorg.libXdmcp.dev
    xorgserver
  ];

  pythonPath = with python3Packages; [
    pycairo
    pygobject3
  ];

  postInstall = ''
    sed -i "s|/usr/bin/metacity|${gnome.metacity}/bin/metacity|" $out/bin/compiz-decorator
    sed -i "s|/usr/bin/compiz-decorator|$out/bin/compiz-decorator|" $out/share/compiz/decor.xml
    wrapProgram $out/bin/compiz \
      --prefix LD_LIBRARY_PATH : "$out/lib" \
      --prefix COMPIZ_BIN_PATH : "$out/bin/"
    wrapPythonPrograms
  '';

  patches = [
    ./reverse-unity-config.patch
    ./focus-prevention-disable.patch
    ./gtk-extents.patch
    ./screenshot-launch-fix.patch
    ./no-compile-gschemas.patch
  ];

  cmakeFlags = [
    "-DCMAKE_CXX_STANDARD=17"
    "-DCMAKE_BUILD_TYPE='Release'"
    "-DCOMPIZ_DISABLE_SCHEMAS_INSTALL=ON"
    "-DCOMPIZ_BUILD_WITH_RPATH=OFF"
    "-DCOMPIZ_PACKAGING_ENABLED=ON"
    "-DBUILD_GTK=ON"
    "-DBUILD_METACITY=ON"
    "-DBUILD_KDE4=OFF"
    "-DCOMPIZ_DEFAULT_PLUGINS='composite,opengl,decor,resize,place,move,compiztoolbox,staticswitcher,regex,animation,wall,ccp'"
    "-DCOMPIZ_BUILD_TESTING=OFF"
    "-DCOMPIZ_WERROR=OFF"
    "-Wno-dev"
  ];
})
