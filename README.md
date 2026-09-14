# NixOS running on RK3588/RK3588s

> :warning: Work in progress, use at your own risk...

A minimal flake to run NixOS on RK3588/RK3588s based SBCs, support both UEFI & U-Boot.

Since this flake was started, some boards (Pi 5, Pi 5 Plus) got upstream Nixpkgs support.
The upstream support does not cover all boards yet,
  and has some differences with vendor-provided kernel (for example, different NPU interfaces).
The flake still exists to provide system configs and SD card images based on vendor kernel and U-Boot,
  since some may prefer them over upstream at the moment.

If you want to make an SD card image for your board using upstream packages (without using this flake),
  see [this example config](./examples/upstream-opi/) for Pi 5 Plus.
If the example config works for you, you don't need this flake.

## Boards

UEFI support:

| Singal Board Computer | Boot from SD card  | Boot from SSD      |
| --------------------- | ------------------ | ------------------ |
| Orange Pi 5           | :heavy_check_mark: | :heavy_check_mark: |
| Orange Pi 5 Plus      | :heavy_check_mark: | :heavy_check_mark: |
| Rock 5A               | :no_entry_sign:    | :no_entry_sign:    |

U-Boot support:

| Singal Board Computer | Boot from SD card  | Boot from SSD      |
| --------------------- | ------------------ | ------------------ |
| Orange Pi 5           | :heavy_check_mark: | :heavy_check_mark: |
| Orange Pi 5 Plus      | :heavy_check_mark: | :heavy_check_mark: |
| Rock 5A               | :heavy_check_mark: | :no_entry_sign:    |

### FriendlyELEC UEFI images

CM3588 NAS, NanoPC-T6, NanoPC-T6 LTS and NanoPi R6C use the existing Armbian vendor
kernel with their respective vendor DTBs. These integrations are evaluation-checked;
full image builds and hardware boot/peripheral testing are separate validation steps.
No proprietary GPU userspace is added. CM3588 cooling still needs host-specific
validation: the vendor DTB leaves the PWM fan disabled.

| Board | Core module under `nixosModules.boards` | Image package |
| --- | --- | --- |
| CM3588 NAS | `cm3588-nas.core` | `rawEfiImage-cm3588-nas` |
| NanoPC-T6 | `nanopc-t6.core` | `rawEfiImage-nanopc-t6` |
| NanoPC-T6 LTS | `nanopc-t6-lts.core` | `rawEfiImage-nanopc-t6-lts` |
| NanoPi R6C | `nanopi-r6c.core` | `rawEfiImage-nanopi-r6c` |

Build, for example, with `nix build .#rawEfiImage-cm3588-nas` (requires an
AArch64 builder or emulation). The corresponding configuration is
`nixosConfigurations.cm3588-nas-uefi`; the other boards use the same `-uefi` suffix.
These raw UEFI disk images can be written to SD media and require compatible
board-specific firmware already flashed. **Locate the firmware before writing an
image: a whole-disk raw image must not overwrite firmware on the same SD/eMMC
medium.** Use separate OS media or a separately planned installation preserving
the firmware's reserved area and partition layout. They contain no firmware, and these
boards export no U-Boot `sdImage` packages or SD-image modules.

Use Linux Device Tree mode and the Vendor compatibility setting for this kernel;
record and verify the firmware version and settings before booting. See the
[EDK2 device-tree guidance](https://github.com/edk2-porting/edk2-rk3588#device-tree-configuration),
including its warnings about firmware fixups when supplying an external DTB.
The new core modules preserve systemd-boot's native per-generation processed DTB
installation and do not import the shared `/boot/dtb` installer.
Their image-specific modules select systemd-boot inside the generated raw-efi
configuration, replacing that format's default GRUB loader only for these boards.
Images default to two boot-menu generations to bound usage of the approximately
249 MiB ESP. Check free space before updates, especially with larger custom
initrds; the generation limit does not guarantee they will fit.
For a custom host, import its core module, provide `specialArgs.rk3588.pkgsKernel`
as an AArch64 package set, and configure systemd-boot and filesystems yourself.
Demo images retain the default account documented below; change its credentials
before exposing a machine to the network.

#### NanoPi R6C validation status

The R6C is RK3588S. Its existing pinned vendor DTB is
`rockchip/rk3588s-nanopi-r6c.dtb`: the R6C DTS inherits the R6S DTS and common
R6 description, then overrides board identity, GPIO-header line names, the user
LED (formerly LAN2), PWM0/PWM1 m2 pins and the second PCIe lane for M.2.
The included one-line kernel patch corrects deletion of the inherited R6S-only
PCIe NIC node after Armbian renamed it. Retain these R6C overrides when updating
the shared DTS; an R6S DTB is not a substitute.
[Pinned R6C DTS](https://github.com/armbian/linux-rockchip/blob/b908c7339f51eddcfe8402cd15d1e1f8f4e67c29/arch/arm64/boot/dts/rockchip/rk3588s-nanopi-r6c.dts)

Use R6C-specific EDK2 with **Device Tree / Vendor** compatibility. Record its
version, storage location and override settings. systemd-boot supplies the selected
processed DTB per generation; check the generated boot entry and effective DT
identity, and ensure any old `/boot/dtb/base` override does not defeat generation
selection or rollback. The vendor model is `FriendlyElec NanoPi R6C`, with
compatibles `friendlyelec,nanopi-r6c` and `rockchip,rk3588`.
[EDK2 firmware and DT guidance](https://github.com/edk2-porting/edk2-rk3588#readme)

The board module selects the vendor UART2 FIQ console, `ttyFIQ0` at 1500000 baud.
Confirm serial recovery with cold-boot logs and `/proc/consoles`. DT-only
compilation and structural checks have passed; full kernel/image builds and
hardware validation remain pending. Validate SD/eMMC, NVMe, USB, GPIO/LED/PWM,
GPU/media workloads and booting both current and rollback generations.

Test both Ethernet ports, including firmware loading, driver binding, MAC
addresses, DHCP, negotiated link and sustained traffic. The pinned in-tree
`r8169` supports RTL8125A/B and requests `rtl_nic/rtl8125a-3.fw` or
`rtl_nic/rtl8125b-2.fw`; redistributable firmware is enabled by the base module.
No external `r8125` module is added without evidence that the installed NIC
revision needs it. Networking remains a hardware-validation prerequisite.
[Pinned r8169 driver](https://github.com/armbian/linux-rockchip/blob/b908c7339f51eddcfe8402cd15d1e1f8f4e67c29/drivers/net/ethernet/realtek/r8169_main.c)

## TODO

- [ ] UEFI support for Rock 5A, Rock 5B, Orange Pi 5B, NanoPi R6S.
- [ ] Complete NanoPi R6C image-build and hardware validation listed above.
- [ ] verify all the hardware features available by RK3588/RK3588s
  - [x] ethernet (rj45)
  - [x] m.2 interface(pcie & sata)
  - [x] wifi/bluetooth
  - [x] audio
  - [x] gpio
  - [x] uart/ttl
  - [x] gpu(mali-g610-firmware + panthor)
  - [x] npu (works with [rkllama](https://github.com/NotPunchnox/rkllama), tested on OPi 5 Plus)
  - ...

## Flash & Boot NixOS

Default user: `rk`, default password: `rk3588`

The SD card images built using this flake do not embed a bootloader,
  and won't boot directly on a new board
  (unlike Armbian images that do embed U-Boot and just run out of the box).
You have to manually install a bootloader (UEFI or U-Boot) into the SPI flash of your board.
To do that, you boot into an Armbian image and write a precompiled bootloader image into your SPI block device under `/dev`
  — detailed instructions are given under links below.
Once a bootloader is in SPI, you can boot NixOS images from this repo
  (although make sure your NixOS config is set to use the right bootloader).

This flake supports UEFI and U-Boot, here are the install steps:

- [UEFI.md](./UEFI.md)
- [U-Boot.md](./U-Boot.md)

I personally recommend running U-Boot, as our support for UEFI has known bugs (https://github.com/gnull/nixos-rk3588/issues/1).

Feel free to drop a testing report in the associated [discussions page](https://github.com/gnull/nixos-rk3588/discussions/2).

## Optional vendor Mali OpenCL

For opt-in, headless Mali G610 OpenCL (including tone-mapping), see
[the module example and compatibility requirements](./examples/mali-opencl/README.md).

## Debug via serial port(UART)

See [Debug.md](./Debug.md)

## Custom Deployment

You can use this flake as an input to build your own configuration.
Here is an example configuration that you can use as a starting point: [Demo - Deployment](./examples/demo).

The demo above uses Colmena with remote deployments.
If you want something more basic, just create a [regular system config with flakes](https://nixos-and-flakes.thiscute.world/nixos-with-flakes/nixos-with-flakes-enabled)
  and import `nixos-rk3588.nixosModules.${board}` as well as `nixos-rk3588.nixosModules.${board}.sd-image`
  modules provided by this flake.

## How this flake works

A complete Linux system typically consists of five components:

1. Bootloader (typically U-Boot or EDKII)
1. Linux kernel
1. Device trees
1. Firmwares
1. Root file system (rootfs)

Among these, the bootloader, the kernel, device trees, and firmwares are hardware-related and require customization for different SBCs.
On the other hand, the majority of content in the rootfs is hardware-independent and can be shared across different SBCs.

Hence, the fundamental approach here is to **use the hardware-specific components(bootloader, kernel, and device trees, firmwares) provided by the vendor(orangepi/rockpi/...), and combine them with the NixOS rootfs to build a comprehensive system**.

Regarding RK3588/RK3588s, a significant amount of work has been done by Armbian on their kernel, and device tree.
Therefore, by integrating these components from Armbian with the NixOS rootfs, we can create a complete NixOS system.

The primary steps involved are:

1. Bootloader: Since no customization is required for U-Boot or [edk2-rk3588], it's also possible to directly use the precompiled image from [armbian], [edk2-rk3588], or the hardware vendor.
2. Build the NixOS rootfs using this flake, leveraging the kernel and device tree provided by [armbian].
   - To make all the hardware features available, we need to add its firmwares to the rootfs. Since there is no customization required for the firmwares too, we can directly use the precompiled firmwares from Armbian & Vendor too.

## Screenshots

![Orange Pi 5 Plus Neofetch](_img/nixos-orangepi5plus.webp)
![ROCK 5A Neofetch](_img/nixos-rock5a.webp)

## References

- [K900/nix](https://gitlab.com/K900/nix)
- [aciceri/rock5b-nixos](https://github.com/aciceri/rock5b-nixos)
- [nabam/nixos-rockchip](https://github.com/nabam/nixos-rockchip)
- [fb87/nixos-orangepi-5x](https://github.com/fb87/nixos-orangepi-5x)
- [dvdjv/socle](https://github.com/dvdjv/socle)
- [edk2-rk3588]

And I also got a lot of help in the [NixOS on ARM Matrix group](https://matrix.to/#/#nixos-on-arm:nixos.org)!

[edk2-rk3588]: https://github.com/edk2-porting/edk2-rk3588
[armbian]: https://github.com/armbian/build
