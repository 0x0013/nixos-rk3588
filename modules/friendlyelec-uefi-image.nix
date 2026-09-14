{ ... }: {
  # Apply inside the generated image configuration, where raw-efi enables GRUB.
  formatConfigs.rk3588-raw-efi = { lib, ... }: {
    boot.loader.grub.enable = lib.mkForce false;
    boot.loader.systemd-boot.enable = lib.mkForce true;
    boot.loader.systemd-boot.installDeviceTree = true;
    # The raw-efi format has a small ESP; retain one rollback generation
    # without accumulating an unbounded set of kernels, initrds and DTBs.
    boot.loader.systemd-boot.configurationLimit = lib.mkDefault 2;
    boot.loader.efi.canTouchEfiVariables = false;
  };
}
