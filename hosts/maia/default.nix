{ pkgs, inputs, ... }: {
  imports = [
    inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-gpu-nvidia
    inputs.hardware.nixosModules.common-pc-ssd

    ./hardware-configuration.nix

    ../common/global
    ../common/users/misterio.nix
    ../common/users/layla.nix

    ../common/optional/quietboot.nix
    ../common/optional/tailscale.nix
  ];

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_zen;
  };

  hardware.nvidia.prime.offload.enable = false;
  system.stateVersion = "22.05";
  # TODO: Add graphical stuff
  # GNOME seems broken
}
