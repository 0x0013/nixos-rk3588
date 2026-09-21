{ ... }: {
  imports = [ (import ./friendlyelec.nix "nanopc-t6-rk3588_defconfig") ];
  boot.kernelParams = [ "console=ttyFIQ0,1500000" ];
}
