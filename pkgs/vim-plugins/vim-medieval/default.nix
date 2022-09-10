{ vimUtils, fetchFromGitHub }:
let
  pname = "vim-medieval";
in
vimUtils.buildVimPlugin {
  inherit pname;
  version = "2022-02-07";
  dontBuild = true;
  src = fetchFromGitHub {
    owner = "gpanders";
    repo = "${pname}";
    rev = "029ba76340cc51d481d5fa0ad19e25b0ee13b3c5";
    sha256 = "sha256-JYkevNxW/RYLVfxXSGYvVSQwmjk2zSvzxLVTbR0lzek=";
  };
  patches = [ ./preview-instead-of-scratch.patch ];
}
