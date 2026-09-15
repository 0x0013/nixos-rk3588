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
    rev = "f694b5f9d122192cd4af529dc279b22b4cc703c3";
    hash = "sha256-b0AVSfL1T985KvTTLRV3yN5EkxgkQLjY8g9F9nnnTEo=";
  };

  kernelPatches = [
    {
      name = "nanopi-r6c-pcie-node";
      patch = ./patches/nanopi-r6c-pcie-node.patch;
    }
  ];

  # Preserve the integration config, with Armbian's rkr7.2 Valhall selection.
  # Keep the config file and its Nix representation in sync when changing it.
  configfile = ./rk35xx_vendor_config;
  config = import ./rk35xx_vendor_config.nix;
}).overrideAttrs (old: {
  # Matches CONFIG_EFI_STUB=y; expose it also with linuxManualConfig.
  passthru = (old.passthru or {}) // {
    features = (old.passthru.features or {}) // { efiBootStub = true; };
  };
  name = "k"; # dodge uboot length limits
  nativeBuildInputs = old.nativeBuildInputs ++ [ ubootTools ];

  # Valhall embeds mali_csffw.h, which also works with separate build/source dirs.
})
