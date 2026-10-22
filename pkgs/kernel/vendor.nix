{ fetchFromGitHub
, linuxManualConfig
, ubootTools
, ...
}:
let
  modDirVersion = "6.1.172";
in
(linuxManualConfig {
  inherit modDirVersion;
  version = "${modDirVersion}-armbian";
  extraMeta.branch = "rk-6.1-rkr7.2";

  src = fetchFromGitHub {
    owner = "armbian";
    repo = "linux-rockchip";
    rev = "f282cec8b015759a6ae317226505b3a6c8e9e3e2";
    hash = "sha256-tM74906x5+fO4+I0sWhuuTJZeX+606NyfyvFPGrZRh0=";
  };

  kernelPatches = [
    {
      name = "friendlyelec-dynamic-cma";
      patch = ./patches/friendlyelec-dynamic-cma.patch;
    }
    {
      name = "nanopi-r6-hdmi-phy";
      patch = ./patches/nanopi-r6-hdmi-phy.patch;
    }
    {
      name = "nanopi-r6c-pcie-node";
      patch = ./patches/nanopi-r6c-pcie-node.patch;
    }
  ];

  # Preserve the integration config, with Armbian's rkr7.2 Valhall selection.
  # linuxManualConfig reads y/m metadata directly from this raw config.
  configfile = ./rk35xx_vendor_config;
}).overrideAttrs (old: {
  # Matches CONFIG_EFI_STUB=y; required by systemd-boot on newer nixpkgs.
  passthru = (old.passthru or { }) // {
    features = ((old.passthru or { }).features or { }) // { efiBootStub = true; };
  };
  name = "k"; # dodge uboot length limits
  nativeBuildInputs = old.nativeBuildInputs ++ [ ubootTools ];

  # Valhall embeds mali_csffw.h, which also works with separate build/source dirs.
})
