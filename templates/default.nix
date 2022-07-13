{
  c = {
    description = "C/C++ environment (clang)";
    path = ./c;
  };
  document = {
    description = "Document building environment (pandoc)";
    path = ./document;
  };
  haskell = {
    description = "Haskell environment (cabal)";
    path = ./haskell;
  };
  jekyll = {
    description = "Jekyll website";
    path = ./jekyll;
  };
  rust = {
    description = "Rust environment (cargo)";
    path = ./rust;
  };
  zip = {
    description = "Simple Zip package";
    path = ./zip;
  };
}
