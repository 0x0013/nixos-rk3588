# R6C uses the vendor UART2 FIQ console rather than ttyS2.
{ rk3588, ... }:
let
  pkgsKernel = rk3588.pkgsKernel;
in {
  imports = [ ./base.nix ./dtb-install.nix ];

  boot.kernelPackages = pkgsKernel.linuxPackagesFor (pkgsKernel.callPackage ../../pkgs/kernel/vendor.nix {});
  boot.kernelParams = [
    "earlycon"
    "console=ttyFIQ0,1500000"
    "console=tty1"
  ];

  hardware.deviceTree.enable = true;
  hardware.deviceTree.name = "rockchip/rk3588s-nanopi-r6c.dtb";
}
