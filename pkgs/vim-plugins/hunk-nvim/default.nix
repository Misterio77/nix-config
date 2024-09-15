{
  vimUtils,
  fetchFromGitHub,
}:
vimUtils.buildVimPlugin {
  pname = "hunk-nvim";
  version = "2021-11-15";
  dontBuild = true;
  src = fetchFromGitHub {
    owner = "julienvincent";
    repo = "hunk.nvim";
    rev = "0834cb91c9eb1f315fbf49ad4ea9abc9ac8b5157";
    sha256 = "sha256-wtR2mPPmBK99loE1pOKqrRY8mHrTT5WsO8085wOuPuM=";
  };
  meta.homepage = "https://github.com/julienvincent/hunk.nvim";
}
