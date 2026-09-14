# Optional Mali G610 OpenCL

Add this to your existing aarch64-linux NixOS configuration, with this flake
available as the `nixos-rk3588` input:

```nix
{ inputs, lib, pkgs, ... }: {
  imports = [ inputs.nixos-rk3588.nixosModules.mali-g610-opencl ];
  nixpkgs.config.allowUnfreePredicate = pkg:
    lib.getName pkg == "mali-g610-opencl";
  hardware.mali-g610-opencl.enable = true;
  environment.systemPackages = [ pkgs.clinfo ];
}
```

Merge the unfree predicate with any existing policy. The module defaults off;
no board imports it automatically. It registers the absolute library path via
`hardware.graphics.extraPackages` and the NixOS OpenCL vendor directory. It
installs no EGL/GLES/GBM replacement symlinks and changes no GPU kernel driver,
device tree, firmware, device permissions, or application services.

The aarch64-only package export is `packages.aarch64-linux.mali-g610-opencl`:

```sh
NIXPKGS_ALLOW_UNFREE=1 nix build --impure .#packages.aarch64-linux.mali-g610-opencl
```

## Compatibility and validation

This preserves the previously working Jellyfin tone-mapping binary:
`libmali-valhall-g610-g13p0-gbm.so`, JeffyCN/mirrors revision
`9b410e6c7e7f608458a81376c93480fb19faaee2`.
The prior deployment used Armbian Linux 6.1.115, revision
`fd9f82366e235b8afbdf516765210e97d24dce93`, with the vendor Mali driver and
kernel-embedded G25p0 firmware. The unused standalone G24p0 firmware from the
old expression is deliberately omitted; userspace and firmware version labels
are separate. This is historical compatibility evidence, not a hardware test
of the current main kernel pin.

You must supply a compatible vendor Mali kernel interface (`/dev/mali0`).
Panthor/Mesa alone does not establish compatibility with this proprietary ICD.
On the target, check driver binding, firmware load and service-user access to
the device, then run `clinfo` as that user and an actual HDR-to-SDR OpenCL job.
MPP/FFmpeg/RGA configuration and container device/library exposure are separate
requirements. Package builds and module evaluation cannot verify these workloads.

## License and redistribution

The pinned [ARM EULA](https://github.com/JeffyCN/mirrors/blob/9b410e6c7e7f608458a81376c93480fb19faaee2/END_USER_LICENCE_AGREEMENT.txt)
is LES-PRE-20769, SP-Version 1.0 (25 November 2015).
The pinned [copyright manifest](https://github.com/JeffyCN/mirrors/blob/9b410e6c7e7f608458a81376c93480fb19faaee2/debian/copyright)
assigns that EULA to `lib/*`; GPL packaging scripts do not license the binary.
Both files are retained under `share/licenses/mali-g610-opencl`.

The EULA restricts use to Mali-based Applications. Clauses 1.1(ii) and 1.2 allow
conditional redistribution of the whole software, or subsets together with
Applications, with notices and license retained. This package contains only a
subset, so its metadata conservatively sets `free = false` and
`redistributable = false` rather than assuming standalone binary-cache rights.
Review the full terms before use or distribution; enabling unfree evaluation
does not grant additional rights.
