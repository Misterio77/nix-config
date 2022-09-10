{ vimUtils, fetchFromGitHub }:
let
  pname = "vim-syntax-shakespeare";
in
vimUtils.buildVimPlugin {
  inherit pname;
  version = "2021-12-14";
  dontBuild = true;
  src = fetchFromGitHub {
    owner = "pbrisbin";
    repo = pname;
    rev = "2f4f61eae55b8f1319ce3a086baf9b5ab57743f3";
    sha256 = "sha256-sdCXJOvB+vJE0ir+qsT/u1cHNxrksMnqeQi4D/Vg6UA=";
  };
  meta.homepage = "https://github.com/pbrisbin/${pname}";
}
