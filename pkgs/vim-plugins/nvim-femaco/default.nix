{ vimUtils, fetchFromGitHub }: vimUtils.buildVimPlugin {
  pname = "nvim-femaco";
  version = "2022-10-10";
  dontBuild = true;
  src = fetchFromGitHub {
    owner = "acksld";
    repo = "nvim-femaco.lua";
    rev = "469465fc1adf8bddc2c9bbe549d38304de95e9f7";
    sha256 = "sha256-fayT1gtbxO0B3qK3pISsgarFVL9Kt/NWOyI26+S9Y+c=";
  };
  meta.homepage = "https://github.com/AckslD/nvim-FeMaco.lua";
}
