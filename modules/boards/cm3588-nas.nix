# =========================================================================
#      CM3588-NAS Specific Configuration
# =========================================================================
{...}: {
  imports = [
    ./nanopibase.nix
  ];

  # add some missing deviceTree in friendlyarm/kernel-rockchip:
  # NanoPC-T6's deviceTree in friendlyarm/kernel-rockchip:
  # https://github.com/armbian/linux-rockchip/blob/rk-6.1-rkr4.1/arch/arm64/boot/dts/rockchip/rk3588-friendlyelec-cm3588-nas.dts
  hardware.deviceTree.name = "rockchip/rk3588-friendlyelec-cm3588-nas.dtb";
}