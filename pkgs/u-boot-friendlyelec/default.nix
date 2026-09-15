{
  buildUBoot,
  rkbin,
  stdenv,
  defconfig,
}:
assert stdenv.hostPlatform.isAarch64;
  buildUBoot {
    inherit defconfig;
    extraMeta.platforms = ["aarch64-linux"];
    # Keep Rockchip's runtime firmware for the vendor kernel's SiP services.
    # DDR v1.18 requires BL31 >= v1.47; nixpkgs pairs it with v1.48.
    # https://github.com/rockchip-linux/rkbin/blob/f43a462e7a1429a9d407ae52b4745033034a6cf9/doc/release/RK3588_EN.md
    BL31 = rkbin.BL31_RK3588;
    ROCKCHIP_TPL = rkbin.TPL_RK3588;
    filesToInstall = ["u-boot-rockchip.bin"];
  }
