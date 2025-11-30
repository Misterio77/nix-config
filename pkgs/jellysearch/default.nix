{
  lib,
  fetchFromGitLab,
  dotnetCorePackages,
  buildDotnetModule,
  sqlite,
}:

buildDotnetModule rec {
  pname = "jellysearch";
  version = "0.1";

  src = fetchFromGitLab {
    owner = "DomiStyle";
    repo = "jellysearch";
    rev = "7397e3f8c7daa6f0d30b22dda7c5159a913ca6b8";
    hash = "sha256-7t0j4S5A9yvRN8zjToMNsxJ72OjU3j++EAqq9CKcPaI=";
  };

  propagatedBuildInputs = [ sqlite ];

  projectFile = "src/JellySearch/JellySearch.csproj";
  executables = [ "jellysearch" ];
  nugetDeps = ./deps.json;
  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  dotnet-runtime = dotnetCorePackages.aspnetcore_8_0;

  meta = with lib; {
    description = "A fast full-text search proxy for Jellyfin";
    homepage = "https://gitlab.com/DomiStyle/jellysearch";
    license = licenses.mit;
    mainProgram = "jellysearch";
    platforms = dotnet-runtime.meta.platforms;
  };
}
