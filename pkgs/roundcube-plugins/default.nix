{pkgs}: {
  kolab-calendar = pkgs.callPackage ./kolab-calendar {};
  kolab-libcalendaring = pkgs.callPackage ./kolab-libcalendaring {};
  kolab-libkolab = pkgs.callPackage ./kolab-libkolab {};
}

