{ ... }: {
  imports = [ ./friendlyelec.nix ];
  hardware.deviceTree.name = "rockchip/rk3588-nanopc-t6.dtb";
}
