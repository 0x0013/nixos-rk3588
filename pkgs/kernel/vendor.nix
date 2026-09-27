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
    rev = "85233a85b67928000afc2e966bab86a8c414f1b4";
    hash = "sha256-66758y8xChgCE8TPY6GsLRMpW+J19I5yqJ/0REocSpo=";
  };

  kernelPatches = [
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
