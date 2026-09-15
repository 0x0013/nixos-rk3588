# U-Boot's control DT is selected by defconfig. Linux uses the board core's DTB.
defconfig: {
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: let
  uboot = pkgs.callPackage ../../pkgs/u-boot-friendlyelec {inherit defconfig;};
in {
  imports = [
    "${modulesPath}/profiles/base.nix"
    "${modulesPath}/installer/sd-card/sd-image.nix"
  ];

  boot.loader = {
    grub.enable = false;
    systemd-boot.enable = false;
    generic-extlinux-compatible.enable = true;
  };

  system.build.uboot = uboot;

  sdImage = {
    # Leave room for the combined Rockchip DDR/SPL/BL31/U-Boot image.
    firmwarePartitionOffset = 32;
    populateFirmwareCommands = "";
    # Keep image creation and later nixos-rebuild updates on the same /boot.
    populateRootCommands = ''
      mkdir -p ./files/boot
      ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./files/boot
    '';
    postBuildCommands = ''
      test $(stat -c %s ${uboot}/u-boot-rockchip.bin) -le $(( ${toString config.sdImage.firmwarePartitionOffset} * 1024 * 1024 - 32768 ))
      dd if=${uboot}/u-boot-rockchip.bin of=$img bs=512 seek=64 conv=notrunc
    '';
  };

  # R6 cores already select the vendor FIQ console. Add it for CM/T6 SD boot.
  boot.kernelParams = lib.mkAfter (lib.optional
    (builtins.elem defconfig ["cm3588-nas-rk3588_defconfig" "nanopc-t6-rk3588_defconfig"])
    "console=ttyFIQ0,1500000");
}
