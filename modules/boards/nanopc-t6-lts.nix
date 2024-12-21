# =========================================================================
#      NanoPC-T6 Specific Configuration
# =========================================================================
{pkgs, ...}: {
  imports = [
    ./nanopibase.nix
  ];

  # add some missing deviceTree in friendlyarm/kernel-rockchip:
  # NanoPC-T6's deviceTree in friendlyarm/kernel-rockchip:
  #    https://github.com/friendlyarm/kernel-rockchip/blob/nanopi6-v6.1.y/arch/arm64/boot/dts/rockchip/rk3588-nanopc-t6-lts.dtb
  hardware = {
    deviceTree = {
      name = "rockchip/rk3588-nanopc-t6-lts.dtb";
      overlays = [];
    };

    firmware = [(pkgs.callPackage ../../pkgs/mali-firmware {})];
  };
}
