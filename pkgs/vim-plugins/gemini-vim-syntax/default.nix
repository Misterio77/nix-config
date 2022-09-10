{ vimUtils, fetchFromGitea }:
let
  pname = "gemini-vim-syntax";
in
vimUtils.buildVimPlugin {
  inherit pname;
  version = "2021-11-15";
  dontBuild = true;
  src = fetchFromGitea {
    domain = "tildegit.org";
    owner = "sloum";
    repo = pname;
    rev = "596d1f36b386e5b2cc1af4f2f8285134626878d1";
    sha256 = "sha256-4Ma74KdAWtr00NNV0DbDL0SwY6s4d2Ok1HaUvVzCrMA=";
  };
  meta.homepage = "https://tildegit.org/sloum/${pname}";
}
