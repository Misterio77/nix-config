{ roundcubePlugins, fetchFromGitHub }:

roundcubePlugins.roundcubePlugin rec {
  pname = "custom_from";
  version = "1.6.5";

  src = fetchFromGitHub {
    owner = "r3c";
    repo = pname;
    rev = version;
    sha256 = "sha256-fCQbDf8GcHAgo8nft4uYHZDk45VZDY+fgyVrYjGLuu4=";
  };
}
