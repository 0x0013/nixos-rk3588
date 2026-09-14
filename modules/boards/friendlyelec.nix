# Common vendor-kernel support for the FriendlyELEC RK3588 boards.
{ lib, rk3588, ... }:
let
  pkgsKernel = rk3588.pkgsKernel;
in {
  imports = [ ./base.nix ];

  boot.kernelPackages = pkgsKernel.linuxPackagesFor (pkgsKernel.callPackage ../../pkgs/kernel/vendor.nix {});
  boot.kernelParams = [
    "earlycon"
    "console=ttyS2,1500000"
    "console=tty1"
  ];

  hardware.deviceTree.enable = true;
  # Let systemd-boot install the processed DTB alongside each generation.
  boot.loader.systemd-boot.installDeviceTree = lib.mkDefault true;
}
