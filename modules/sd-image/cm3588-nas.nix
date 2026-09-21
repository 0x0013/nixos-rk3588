{ ... }: {
  imports = [ (import ./friendlyelec.nix "cm3588-nas-rk3588_defconfig") ];
  boot.kernelParams = [ "console=ttyFIQ0,1500000" ];
}
