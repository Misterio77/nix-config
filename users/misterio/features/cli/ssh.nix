{
  programs.ssh =  {
    enable = true;
    matchBlocks = {
      "gitlab.com" = {
        addressFamily = "inet";
      };
    };
  };
}
