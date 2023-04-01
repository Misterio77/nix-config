#!/usr/bin/env bash
# vim: ts=2 sw=2 fdm=marker fmr={,} fdl=0
# Nixie (c) Karim Vergnes <me@thesola.io>
# Licensed under GNU GPLv2
# Required commands:
#  - tar (with gzip support)
#  - rm, mv, tail, uname, env, chmod, mkdir, tee (coreutils)
#  - git
#  - kill
#  - one of wget, curl or python3 (with SSL support)
#  - sh with source and declare -a
# Requirements for building binaries locally:
#  - A C and C++ compiler toolchain
#  - pkg-config
#  - GNU Make
#  - flex + bison
#  - perl

SYSTEM="$(uname -s).$(uname -m)"
THIS_SCRIPT="$(readlink -f $0)"
PWD_SAVE=$PWD
REPO_ROOT="$({ git -C "${THIS_SCRIPT%/*}" rev-parse --show-toplevel 2>/dev/null | head -n 1; } || { >&2 echo "WARNING: Failed to find current Git repository, using script parent directory."; echo "${THIS_SCRIPT%/*}"; })"

if [[ "$SYSTEM" =~ Darwin ]]
then
  DLL_EXT="dylib"
  USER_STORE="$HOME/Library/Nix"
else
  DLL_EXT="so"
  USER_STORE="$HOME/.local/share/nix/root"
fi

if [[ "$XDG_CACHE_HOME" != "" ]]
then
  USER_CACHE="$XDG_CACHE_HOME"
elif [[ "$SYSTEM" =~ Darwin ]]
then
  USER_CACHE="$HOME/Library/Caches"
else
  USER_CACHE="$HOME/.cache"
fi

##### UTILITY FUNCTIONS #####

# Output an error message to stderr then nuke ourselves
_bail() {
  tput rmcup
  >&2 echo $@
  >&2 echo "This script can be rebuilt using the nixie tool"
  kill -ABRT $$
}

# Pull a file or directory from the resource tarball linked into this
# script. Useful for semi-offline or completely offline operation.
_untar() {
  {
    { read -r M
      while ! [[ "$M" =~ ^-----BEGIN\ ARCHIVE\ SECTION----- ]]
      do read -r M
      done
      gzip -d -c 2>/dev/null
    } < "$THIS_SCRIPT"
  if ! [[ $? =~ ^[02]$ ]]
  then
    # The resource tarball is required since it contains the feature
    # attributes for this script. We bail out since there is no
    # situation where tar failing would bode well.
    _bail "Could not find or decompress resource archive."
  fi
  } | tar -x "$@"
}

# Best-attempt script for downloading files. We first try wget, then cURL,
# then Python 3.
_dl() {
  if which wget >&/dev/null
  then
    wget "$1" -O"$2" || { rm "$2"; return 1; }
  elif which curl >&/dev/null
  then
    curl -f -L "$1" -o "$2"
  elif which python3 >&/dev/null
  then
    python3 <<EOF
from urllib.request import urlopen
with open('$2') as fi:
  with urlopen('$1') as rq:
    fi.write(rq.read())
EOF
  else
    >&2 echo "One of 'wget', 'curl' or 'python3' is required to download files."
    >&2 echo "Install one of these then try again."
    return 1
  fi
}


##### NIX BUILDERS #####

# Download script wrapper to retrieve files from the source derivation this
# script was built with. Requires SOURCE_CACHE to be the host name for a
# Cachix-compatible HTTPS host (i.e. with endpoint /serve/xxx-hash/path)
_pull_source() {
  [[ -d $2 ]] ||
  (
    cd "$USER_CACHE"
    _untar "sources/$1"
    mv "$1" "$2"
  ) || (
    cd "$USER_CACHE"
    _dl "https://$SOURCE_CACHE/serve/$SOURCE_DERIVATION/$1.tar.gz" "$1.tar.gz"
    gzip -d -c "$1.tar.gz" | tar x
    mv "$1" "$2"
    rm "$1.tar.gz"
  )
}

# Idem for static Nix binaries
_pull_nix_bin() {
  (
    cd "$USER_CACHE"
    _untar "$1"
    mv "$1" "$2"
  ) || (
    _dl "https://$SOURCE_CACHE/serve/$NIX_BINS_DERIVATION/$1" "$2"
  )
}

_find_or_build_openssl () {
  pkg-config libcrypto && return 0

  echo -ne "\033]0;Building Nix: libcrypto (1/8)\007"
  _pull_source "openssl" "$source_root/openssl"
  cd "$source_root/openssl"
  chmod +x ./config

  # Did you know? The OpenSSL Makefile doesn't include generated headers to
  # build deps! No one knows how to write a good Makefile nowadays.
  ./config && {
      for hdr in $(grep ".*\\.h:" Makefile | cut -f 1 -d :)
      do
        make $hdr
      done
    } &&
    make libcrypto.$DLL_EXT

  cp ./libcrypto.* "$USER_CACHE/nix-lib/"

  export OPENSSL_LIBS="$USER_CACHE/nix-lib"
  export OPENSSL_CFLAGS="-I$source_root/openssl/include"
}

_find_or_build_autoconf () {
  libname="$1"
  varname="$2"

  echo -ne "\033]0;Building Nix: $libname ($nth/8)\007"
  pkg-config $libname && return 0

  _pull_source "$libname" "$source_root/$libname"
  cd "$source_root/$libname"
  ./configure && make

  cp ./$libpath/.libs/* "$USER_CACHE/nix-lib/"

  eval "export ${varname}_LIBS=$USER_CACHE/nix-lib"
  eval "export ${varname}_CFLAGS=-I$source_root/$libname/$incpfx/include"
}

_find_or_build_lowdown () {
  pkg-config lowdown && return 0

  echo -ne "\033]0;Building Nix: lowdown (4/8)\007"
  _pull_source "lowdown" "$source_root/lowdown"
  cd "$source_root/lowdown"
  ./configure && make

  if [[ "$SYSTEM" =~ Darwin ]]
  then
    # macOS' clang doesn't support the GCC-esque --soname, and the library
    # output name would be wrong anyway.
    cc -shared -o liblowdown.1.dylib *.o
  fi

  cp ./liblowdown.* "$USER_CACHE/nix-lib/"

  export LOWDOWN_LIBS="$USER_CACHE/nix-lib"
  export LOWDOWN_CFLAGS="-I$source_root/lowdown"
}

_find_or_build_nlohmann_json () {
  pkg-config nlohmann_json && return 0

  echo -ne "\033]0;Building Nix: nlohmann_json (3/8)\007"
  _pull_source "nlohmann_json" "$source_root/nlohmann_json"

  export NLOHMANN_JSON_LIBS="$source_root/nlohmann_json/single_include"
  export NLOHMANN_JSON_CFLAGS="-I$source_root/nlohmann_json/single_include"
}

_find_or_build_boost () {
  boost_libs=(atomic chrono container context system thread)
  for lb in ${boost_libs[@]}
  do
    [[ -f /usr/lib/libboost_$lb* ]] || \
    [[ -f /usr/local/lib/libboost_$lb* ]] || boost_not_found=1 && break
    [[ -f /usr/include/boost/$lb ]] || \
    [[ -f /usr/local/include/boost/$lb ]] || boost_not_found=1 && break
  done

  [[ $boost_not_found == 1 ]] || return 0

  echo -ne "\033]0;Building Nix: boost (2/8)\007"
  _pull_source "boost" "$source_root/boost"
  cd "$source_root/boost"
  ./bootstrap.sh && ./b2 --with-system --with-thread --with-context --with-container --with-chrono --static

  export BOOST_ROOT="$source_root/boost"
}

# Check that we have the required dependencies to build Nix locally, then
# do so.
_try_build_nix() {
  source_root="$REPO_ROOT/.nixie/sources"
  mkdir -p $source_root

  _find_or_build_openssl
  _find_or_build_boost
  _find_or_build_nlohmann_json
  _find_or_build_lowdown
  libpath=              incpfx=c              nth=5\
      _find_or_build_autoconf libbrotlicommon LIBBROTLI
  libpath=src/libsodium incpfx=src/libsodium  nth=6\
      _find_or_build_autoconf libsodium       SODIUM
  libpath=src           incpfx=               nth=7\
      _find_or_build_autoconf libeditline     EDITLINE

  echo -ne "\033]0;Building Nix (8/8)\007"
  _pull_source "nix" "$source_root/nix"

  cd "$source_root/nix"

  # Populate macOS SDK paths
  if [[ "$SYSTEM" =~ Darwin ]]
  then
    macos_sdk="$(xcrun --show-sdk-path)"
    [[ -d $macos_sdk ]] || _bail "The macOS SDK from Xcode or CommandLineTools is required to build Nix."

    export LIBCURL_LIBS=$macos_sdk/usr/lib
    export LIBCURL_CFLAGS=$macos_sdk/usr/include
    export LIBARCHIVE_LIBS=$macos_sdk/usr/lib
    export LIBARCHIVE_CFLAGS=$macos_sdk/usr/include
    export OPENSSL_LIBS=$macos_sdk/usr/lib
    export OPENSSL_CFLAGS=$macos_sdk/usr/include
  fi

  ./configure --disable-seccomp-sandboxing \
              --disable-s3 \
              --disable-doc-gen \
              --disable-embedded-sandbox-shell \
              --disable-gc \
              --disable-cpuid \
  && make

  #TODO: determine binary output path and copy to nix-static
  mv nix "$USER_CACHE/nix-static"
}

# Try a set of strategies to obtain a statically built Nix binary
_get_nix() {
  # Acquiring Nix produces a lot of output, so we use alt-buffer.
  tput smcup
  echo -ne "\033]0;Building Nix...\007"

  __teardown() { tput rmcup; echo -ne "\033]0;\007"; }

  # And we set a trap to exit alt-buffer on ^C cause we're no savages.
  trap "__teardown; exit 1" SIGKILL SIGTERM SIGINT SIGABRT

  if [[ $SYSTEM =~ Darwin ]] && ! [[ -f $USER_CACHE/nix-lib/libfakedir.dylib ]]
  then
    # Retrieve fakedir
    mkdir -p "$USER_CACHE/nix-lib"
    _pull_nix_bin "libfakedir.dylib" "$USER_CACHE/nix-lib/libfakedir.dylib"
  fi

  # Check if the binary already exists
  [[ -f "$USER_CACHE/nix-static" ]] \
    && { __teardown; return 0; }

  # Look in our sources for prebuilt binary
  _pull_nix_bin "nix.$SYSTEM" "$USER_CACHE/nix-static" \
    && { __teardown; return 0; }

  # Build Nix locally from source
  _try_build_nix 2>&1 | tee nix-build.log \
    && { __teardown; return 0; }

  # Everything failed, bail out
  __teardown
  return 1
}


##### RUNNER SCRIPTS

_macos_workaround_nix () {
  CMDNAME="$1"
  shift 1
  mkdir -p $USER_STORE/nix

  [[ -f "$USER_CACHE/nix-lib/libfakedir.dylib" ]] || _bail "libfakedir.dylib missing, cannot proceed."

  : ${NIX_SSL_CERT_FILE:=/etc/ssl/cert.pem}
  export NIX_SSL_CERT_FILE

  # We must ensure fakedir gets propagated into spawned executables as well
  # so we unfortunately need to disengage the sandbox entirely.
  _NIX_TEST_NO_SANDBOX=1 \
  DYLD_INSERT_LIBRARIES="$USER_CACHE/nix-lib/libfakedir.dylib" \
  DYLD_LIBRARY_PATH="$USER_CACHE/nix-lib" \
  FAKEDIR_PATTERN=/nix \
  FAKEDIR_TARGET=$USER_STORE/nix \
    exec -a "$CMDNAME" "$USER_CACHE/nix-static" "$@"
}

_catch_nixie_args() {
  __help() {
    >&2 echo "Nix wrapper script, generated by Nixie $NIXIE_VERSION"
    >&2 echo
    >&2 echo "Available --nixie- options:"
    >&2 echo "  --nixie-help            Show this help and exit."
    >&2 echo "  --nixie-print-config    Print this script's configuration"
    >&2 echo "  --nixie-extract         Unpack the resources archive in nixie/"
    >&2 echo "  --nixie-ignore-system   Do not use system-wide Nix"
    >&2 echo "  --nixie-cleanup         Delete local Nix build files"
    exit 0
  }

  __print-config() {
    _untar -O features
    exit 0
  }

  __extract() {
    mkdir -p nixie && cd nixie && _untar
    exit 0
  }

  __cleanup() {
    >&2 echo "Removing local Nix channels and build files..."
    chmod -R +wx $REPO_ROOT/.nixie && rm -rf $REPO_ROOT/.nixie
    >&2 echo "Removing user Nix store..."
    chmod -R +wx $USER_STORE && rm -rf $USER_STORE
    >&2 echo "Removing retrieved Nix binaries..."
    rm -rf $USER_CACHE/nix-static $USER_CACHE/nix-lib
    exit 0
  }

  __ignore-system() {
    >&2 echo "WARNING: Ignoring system-wide Nix for testing purposes."
    >&2 echo "Re-run without the --nixie-ignore-system flag to import the single-user"
    >&2 echo "Nix store into the system store."
    nosystem=1
  }

  for ((i = 0; i < ${#CMDL_ARGS[@]}; ++i))
  do
    arg="${CMDL_ARGS[$i]}"
    if [[ $arg =~ ^--nixie-(.*)$ ]]
    then
      # Drop nixie option from real command line
      unset CMDL_ARGS[$i]
      __${BASH_REMATCH[1]} || {
        >&2 echo "No such option: $arg. Run '$1 --nixie-help' for available options."
        exit 1
      }
    fi
  done
}


##### ENTRY POINT #####

# Load feature attributes of our resource tarball
eval "$(_untar -O features || _bail "The resource archive is missing or malformed.")"

# Running without a specified sources derivation is not supported, even if sources
# are shipped offline.
[[ "$SOURCE_CACHE" != "" ]] || [[ "$SOURCE_DERIVATION" != "" ]] || [[ "$NIX_BINS_DERIVATION" != "" ]] \
  || _bail "The features file in the resource archive is missing or malformed."

mkdir -p "$REPO_ROOT/.nixie"

declare -a EXTRA_ARGS

declare -a CMDL_ARGS=("$@")

NIXCMD="nix"

# Parse --nixie-* args
nosystem=0
_catch_nixie_args "$0"

# Unpack builtin Nix channels for channel-oriented commands
if [[ "$0" =~ nix-(shell|build|env)$ ]]
then
  if (( $(stat -c %W "$REPO_ROOT/.nixie/channels" 2>/dev/null || echo 0) < $(stat -c %W "$THIS_SCRIPT" ) ))
  then
    (cd $REPO_ROOT/.nixie; _untar "channels" 2>/dev/null)
  fi
  export NIX_PATH="$REPO_ROOT/.nixie/channels:$NIX_PATH"
fi


# Emulate nix-shell interpreter behavior
if [[ "$0" =~ nix-shell$ ]] && [[ -f "$1" ]] && ! [[ "$1" =~ .nix$ ]]
then
  {
    read
    IFS=' ' read -a nix_shell_args

    # There is a possibility that argv[1] is a Nix file.
    # Bail if there's no second line shebang.
    [[ "${nix_shell_args[0]}" =~ ^#! ]] || break

    nix_shell_args=("${nix_shell_args[@]:1}")
    [[ "${nix_shell_args[0]}" == "nix-shell" ]] && nix_shell_args=("${nix_shell_args[@]:1}")

    for i in "${!nix_shell_args[@]}"
    do
      [[ "${nix_shell_args[$i]}" == "-i" ]] && {
        nix_shell_args[$i]="--command"
        nix_shell_args[$((i+1))]="${nix_shell_args[$((i+1))]} $*"
      } && break
    done

    # Overwrite shell arguments with real interpreter
    CMDL_ARGS=("${nix_shell_args[@]}")
  } < "$1"
fi

# Command substitution feature
if [[ "$0" =~ nix$ ]] || [[ "$0" =~ nix-(shell|build|env|channel|hash|instantiate|store)$ ]]
then
  NIXCMD="$0"
elif [[ -f "$REPO_ROOT/flake.nix" ]]
then
  # Try to run named command from flake develop
  NIXCMD="nix"
  CMDL_ARGS=("develop" "$REPO_ROOT" "-c" "${0##*/}" "$@")
elif [[ -f "$REPO_ROOT/shell.nix" ]]
then
  # Try to run named command from shell
  NIXCMD="nix-shell"
  CMDL_ARGS=("$REPO_ROOT/shell.nix" "--command" "${0##*/}$(printf ' %q' "$@")")
fi


# Apply experimental features if listed
[[ "$EXTRA_FEATURES" != "" ]] && EXTRA_ARGS+=("--extra-experimental-features" "$EXTRA_FEATURES")

# Apply extra substituters and their signing keys (e.g. cachix) if listed
[[ "$EXTRA_SUBSTITUTERS" != "" ]] && EXTRA_ARGS+=("--extra-substituters" "$EXTRA_SUBSTITUTERS") && nix_daemon_warn=1
[[ "$EXTRA_TRUSTED_PUBLIC_KEYS" != "" ]] && EXTRA_ARGS+=("--extra-trusted-public-keys" "$EXTRA_TRUSTED_PUBLIC_KEYS") && nix_daemon_warn=1


if [[ $nix_daemon_warn == 1 ]] && \
  pgrep nix-daemon >/dev/null 2>&1 && \
  ! grep "trusted-users\s*=.*$(whoami 2>/dev/null)" /etc/nix/nix.conf >/dev/null 2>&1
then
  >&2 echo "This nix wrapper script specifies additional binary caches,"
  >&2 echo "but you are running on a multi-user install as an untrusted user."
  >&2 echo "Cache substitution may not work until you add yourself to"
  >&2 echo "the trusted-users entry in /etc/nix/nix.conf."
fi

if [[ $nosystem != 1 ]] && [[ -d /nix/store ]] && which nix >&/dev/null
then
  # Here, we check that the user just installed Nix proper on their system,
  # so we migrate paths away from their home to avoid duplicates.
  if [[ -d $USER_STORE/nix/store ]]
  then
    >&2 echo "Migrating Nix store to system-wide install..."
    nix copy --from $USER_STORE --all --no-check-sigs &&\
    chmod -R +wx $USER_STORE && rm -rf $USER_STORE
  fi

  exec -a "$NIXCMD" nix "${EXTRA_ARGS[@]}" "${CMDL_ARGS[@]}"
else
  if _get_nix && chmod +x "$USER_CACHE/nix-static"
  then
    # This is required if the Nix binary was built locally.
    # It is highly unlikely that the user has static copies of all the
    # libraries required by Nix, so it's easier to build a shared binary.
    # After all, this binary isn't meant to leave its host machine.
    export LD_LIBRARY_PATH="$USER_CACHE/nix-lib:$LD_LIBRARY_PATH"

    if [[ "$SYSTEM" =~ Darwin ]]
    then
      # wow apple thanks
      _macos_workaround_nix "$NIXCMD" "${EXTRA_ARGS[@]}" "${CMDL_ARGS[@]}"
    else
      # Workaround for ascendant symlinks
      mkdir -p $HOME/.local/share/nix/root
      exec -a "$NIXCMD" "$USER_CACHE/nix-static" \
        --store "$(readlink -f $HOME/.local/share/nix/root)" \
        "${EXTRA_ARGS[@]}" "${CMDL_ARGS[@]}"
    fi
  else
    >&2 echo "Failed to obtain Nix. Check your internet connection."
    exit 1
  fi
fi

# Prevent overrun into resource tarball
exit 1
cat <<DONOTPARSE

-----BEGIN ARCHIVE SECTION-----[?1049h
ã‚ã'dˇ ÌŒÕnÇ@`÷>Öq/§]∏ ú¶ì6ÿ¿`Ïä?ÇEPA£¯ÙEmM”}õ4=ﬂÊNÓ=wf©ÿÌÎ¥ë~ê“È˙•væWÖò∑ŸGﬂ4TMÍ+“/ÿ7;QwOJˇùsœ
®≈è˙„Aµ<„uYä*È/V¢HõAÔöÒ€Áåúz]Ó≥ÀΩ¿Átæˆ3s¬'˙z˙”¿shËXŒ#Ω^z®≈FéEú/èÚ∫Œnë	ıÿÃ‚lÍéW˜[≥8ë„®2Ñ¶eQÚfê6©Hwm£Ïπl⁄Ãıø.E9π€,â≤∂=‰Q‰ï©u¨üDV6≠~^b4úuø>«5E#≤BÜB5z                 ¿ˆì◊ (  [?1049l [2K[37;2m# (tarball data)[0m