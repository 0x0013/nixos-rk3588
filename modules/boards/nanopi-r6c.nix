# R6C uses the vendor UART2 FIQ console rather than ttyS2.
{ rk3588, ... }:
let
  pkgsKernel = rk3588.pkgsKernel;
  # Keep the production boards on the exact previous kernel. Only R6C needs
  # the inherited R6S endpoint removed from its DTB.
  kernel = (pkgsKernel.callPackage ../../pkgs/kernel/vendor.nix {}).overrideAttrs (old: {
    patches = (old.patches or []) ++ [ ../../pkgs/kernel/patches/nanopi-r6c-pcie-node.patch ];
  });
in {
  imports = [ ./base.nix ./dtb-install.nix ];

  boot.kernelPackages = pkgsKernel.linuxPackagesFor kernel;
  boot.kernelParams = [
    "earlycon"
    "console=ttyFIQ0,1500000"
    "console=tty1"
  ];

  hardware.deviceTree.enable = true;
  hardware.deviceTree.name = "rockchip/rk3588s-nanopi-r6c.dtb";
}
