{ pkgs }: {
  gemini-vim-syntax = pkgs.callPackage ./gemini-vim-syntax { };
  vim-syntax-shakespeare = pkgs.callPackage ./vim-syntax-shakespeare { };
}
