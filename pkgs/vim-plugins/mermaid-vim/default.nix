{ vimUtils, fetchFromGitHub }:
vimUtils.buildVimPlugin {
  pname = "mermaid-vim";
  version = "2022-02-15";
  dontBuild = true;
  src = fetchFromGitHub {
    owner = "mracos";
    repo = "mermaid.vim";
    rev = "a8470711907d47624d6860a2bcbd0498a639deb6";
    sha256 = "sha256-LRuuCFamwvBm9e5mbQ8CkGgclEY9iv52uRl/2kGBUc8=";
  };
  meta.homepage = "https://github.org/mracos/mermaid.vim";
}
