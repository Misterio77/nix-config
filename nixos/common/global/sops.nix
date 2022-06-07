{ inputs, ... }: {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];
}
