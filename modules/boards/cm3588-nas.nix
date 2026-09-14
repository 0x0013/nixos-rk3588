{ ... }: {
  imports = [ ./friendlyelec.nix ];
  hardware.deviceTree.name = "rockchip/rk3588-friendlyelec-cm3588-nas.dtb";
}
