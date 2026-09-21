{
  config,
  pkgs,
  ...
}: let
  extraInstallCommands = ''
    ${pkgs.coreutils}/bin/mkdir -p /boot/dtb/base
    ${pkgs.coreutils}/bin/cp -r ${config.hardware.deviceTree.package}/rockchip/* /boot/dtb/base/
    ${pkgs.coreutils}/bin/sync
  '';
in {
  # Keep the shared DTB directory for GRUB consumers. Systemd-boot installs
  # the selected, processed DTB with each generation via installDeviceTree.
  boot.loader.grub.extraInstallCommands = extraInstallCommands;
}
