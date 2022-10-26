{ pkgs }: {
  gemini-vim-syntax = pkgs.callPackage ./gemini-vim-syntax { };
  vim-syntax-shakespeare = pkgs.callPackage ./vim-syntax-shakespeare { };
  vim-medieval = pkgs.callPackage ./vim-medieval { };
  mermaid-vim = pkgs.callPackage ./mermaid-vim { };
  nvim-femaco = pkgs.callPackage ./nvim-femaco { };
}
