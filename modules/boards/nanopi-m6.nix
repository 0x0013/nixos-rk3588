# =========================================================================
#      Nano Pi M6 Specific Configuration
# =========================================================================
{rk3588, ...}: let
  pkgsKernel = rk3588.pkgsKernel;
in {
  imports = [
    ./base.nix
  ];

  boot = {
    kernelPackages = pkgsKernel.linuxPackagesFor (pkgsKernel.callPackage ../../pkgs/kernel-nanopi6/vendor.nix {});

    # kernelParams copy from Armbian's /boot/armbianEnv.txt & /boot/boot.cmd
    kernelParams = [
      "rootwait"

      "earlycon" # enable early console, so we can see the boot messages via serial port / HDMI
      "consoleblank=0" # disable console blanking(screen saver)
      "console=ttyS2,1500000" # serial port
      "console=tty1" # HDMI

      # docker optimizations
      "cgroup_enable=cpuset"
      "cgroup_memory=1"
      "cgroup_enable=memory"
      "swapaccount=1"
    ];
  };

  # add some missing deviceTree in friendlyarm/kernel-rockchip:
  # Nano Pi M6's deviceTree in friendlyarm/kernel-rockchip:
  #    https://github.com/friendlyarm/kernel-rockchip/blob/nanopi6-v6.1.y/arch/arm64/boot/dts/rockchip/rk3588-nanopi6-rev0a.dts
  hardware = {
    deviceTree = {
      name = "rockchip/rk3588-nanopi6-rev0a.dtb";
      overlays = [];
    };

    firmware = [];
  };
}
