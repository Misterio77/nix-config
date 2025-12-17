{pkgs}: {
  kolab-calendar = pkgs.callPackage ./kolab-calendar {};
  kolab-tasklist = pkgs.callPackage ./kolab-tasklist {};
}

