# R6S uses the vendor UART2 FIQ console rather than ttyS2.
{ lib, rk3588, ... }:
let
  pkgsKernel = rk3588.pkgsKernel;
in {
  imports = [ ./base.nix ];

  boot.kernelPackages = pkgsKernel.linuxPackagesFor (pkgsKernel.callPackage ../../pkgs/kernel/vendor.nix {});
  boot.kernelParams = [
    "earlycon"
    "console=ttyFIQ0,1500000"
    "console=tty1"
  ];

  hardware.deviceTree.enable = true;
  hardware.deviceTree.name = "rockchip/rk3588s-nanopi-r6s.dtb";
  boot.loader.systemd-boot.installDeviceTree = lib.mkDefault true;
}
