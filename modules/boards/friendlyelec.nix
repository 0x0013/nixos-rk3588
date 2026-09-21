# Common vendor-kernel support for the FriendlyELEC RK3588 boards.
{ rk3588, ... }:
let
  pkgsKernel = rk3588.pkgsKernel;
in {
  imports = [ ./base.nix ./dtb-install.nix ];

  boot.kernelPackages = pkgsKernel.linuxPackagesFor (pkgsKernel.callPackage ../../pkgs/kernel/vendor.nix {});
  boot.kernelParams = [
    "earlycon"
    "console=ttyS2,1500000"
    "console=tty1"
  ];

  hardware.deviceTree.enable = true;
}
