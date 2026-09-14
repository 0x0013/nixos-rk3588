# Optional Mali G610 OpenCL

Add this to an aarch64-linux NixOS configuration with this flake as the
`nixos-rk3588` input:

```nix
{ inputs, lib, pkgs, ... }: {
  imports = [ inputs.nixos-rk3588.nixosModules.mali-g610-opencl ];
  nixpkgs.config.allowUnfreePredicate = pkg:
    lib.getName pkg == "mali-g610-opencl";
  hardware.mali-g610-opencl.enable = true;
  environment.systemPackages = [ pkgs.clinfo ];
}
```

Merge the unfree predicate with your existing policy. The module is disabled
by default, and no board imports it. It registers the absolute library path via
`hardware.graphics.extraPackages` and the NixOS OpenCL vendor directory. It
installs no EGL/GLES/GBM replacement symlinks and changes no GPU kernel driver,
device tree, firmware, device permissions, or application services.

The aarch64-only package export is `packages.aarch64-linux.mali-g610-opencl`:

```sh
NIXPKGS_ALLOW_UNFREE=1 nix build --impure .#packages.aarch64-linux.mali-g610-opencl
```

## Compatibility and validation

The package uses the binary previously tested with Jellyfin tone-mapping:
`libmali-valhall-g610-g13p0-gbm.so`, JeffyCN/mirrors revision
`9b410e6c7e7f608458a81376c93480fb19faaee2`.
The prior deployment used Armbian Linux 6.1.115, revision
`fd9f82366e235b8afbdf516765210e97d24dce93`, with the vendor Mali driver and
kernel-embedded G25p0 firmware. This package omits the unused standalone G24p0
firmware. Userspace and firmware have separate version labels.
The current kernel pin has not been hardware-tested with this binary.

OpenCL requires a compatible vendor Mali kernel interface at `/dev/mali0`.
Panthor/Mesa alone is insufficient. On the target, check driver binding,
firmware loading and the service user's device access. Run `clinfo` and an
HDR-to-SDR OpenCL job as that user.
Configure MPP/FFmpeg/RGA separately. Containers also need device and library
access. Package builds and module evaluation do not test these workloads.

## License and redistribution

The pinned [ARM EULA](https://github.com/JeffyCN/mirrors/blob/9b410e6c7e7f608458a81376c93480fb19faaee2/END_USER_LICENCE_AGREEMENT.txt)
is LES-PRE-20769, SP-Version 1.0, dated 25 November 2015.
The pinned [copyright manifest](https://github.com/JeffyCN/mirrors/blob/9b410e6c7e7f608458a81376c93480fb19faaee2/debian/copyright)
assigns the EULA to `lib/*`. The packaging scripts' GPL license does not cover the binary.
The package keeps both files under `share/licenses/mali-g610-opencl`.

The EULA restricts use to Mali-based Applications. Clauses 1.1(ii) and 1.2 allow
conditional redistribution of the whole software, or subsets together with
Applications, with notices and license retained. This package contains only a
subset. Its metadata sets `free = false` and `redistributable = false` because
standalone binary-cache redistribution rights are unconfirmed.
Review the full terms before use or distribution. Enabling unfree evaluation
does not grant additional rights.
