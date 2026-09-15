# U-Boot

Here we describe how to use U-Boot to boot NixOS on RK3588/RK3588s based SBCs.

## FriendlyELEC SD images

These experimental images include firmware. Firmware builds and module evaluation
pass; hardware boot, peripherals and rollback still need testing.
They use the existing 6.1.115 vendor kernel, without a kernel upgrade.

| Board | Image package | U-Boot defconfig |
| --- | --- | --- |
| CM3588 NAS | `sdImage-cm3588-nas` | `cm3588-nas-rk3588_defconfig` |
| NanoPC-T6 | `sdImage-nanopc-t6` | `nanopc-t6-rk3588_defconfig` |
| NanoPC-T6 LTS | `sdImage-nanopc-t6-lts` | `nanopc-t6-rk3588_defconfig` |
| NanoPi R6C | `sdImage-nanopi-r6c` | `nanopi-r6c-rk3588s_defconfig` |
| NanoPi R6S | `sdImage-nanopi-r6s` | `nanopi-r6s-rk3588s_defconfig` |

Build on a native AArch64 machine or a configured remote AArch64 builder:

```sh
nix build .#sdImage-nanopc-t6
# Firmware alone, without building Linux or an OS image:
nix build .#packages.aarch64-linux.uboot-nanopc-t6
```

The same names apply to the other boards. OS images are under
`result/sd-image/*.img.zst`; firmware packages contain `u-boot-rockchip.bin`.
Custom SD-image configurations import both `nixosModules.boards.<board>.core`
and `nixosModules.boards.<board>.sd-image`.

The intended boot path is BootROM, Rockchip DDR initialization, U-Boot SPL,
BL31, U-Boot, then extlinux and Linux. The combined firmware starts at sector
64, before partitions beginning at 32 MiB. The standard NixOS MBR layout has
an empty FAT partition followed by bootable ext4 root, labelled `NIXOS_SD`.
`/boot/extlinux/extlinux.conf` and its kernel, initrd and processed vendor DTB
are on root. Later `nixos-rebuild` updates write to that same `/boot`.
[U-Boot Rockchip image format](https://docs.u-boot.org/en/v2025.10/board/rockchip/rockchip.html#package-the-image-with-u-boot-tpl-spl)

U-Boot 2025.10 and rkbin are pinned through `flake.lock`'s nixpkgs input.
Rockchip BL31 v1.48 is used for the vendor kernel's runtime firmware services.
DDR v1.18 requires BL31 v1.47 or newer. Rockchip lists LP4/LP4x 32 GB support
since DDR v1.09, but individual board RAM variants remain untested here.
Check detected memory and DMC frequency changes on the actual board.
[Rockchip firmware release notes](https://github.com/rockchip-linux/rkbin/blob/f43a462e7a1429a9d407ae52b4745033034a6cf9/doc/release/RK3588_EN.md)

T6 and T6 LTS share firmware with upstream ADC-based board detection.
Their Linux images still select separate vendor DTBs explicitly.
R6C and R6S use separate U-Boot configurations and Linux DTBs.
[T6 detection](https://github.com/u-boot/u-boot/blob/v2025.10/board/friendlyelec/nanopc-t6-rk3588/nanopc-t6-rk3588.c),
[R6C configuration](https://github.com/u-boot/u-boot/blob/v2025.10/configs/nanopi-r6c-rk3588s_defconfig),
[R6S configuration](https://github.com/u-boot/u-boot/blob/v2025.10/configs/nanopi-r6s-rk3588s_defconfig)

Use UART2 at 1500000 baud for the first boot. The SD module adds the vendor
`ttyFIQ0` console. Verify the firmware banner, RAM size, selected DTB, storage,
each Ethernet port, cooling and a rollback generation before deployment.

Existing SPI/eMMC firmware may take precedence over SD firmware. Record where
EDK2 is installed and keep a recovery path. An EDK2 menu means this U-Boot path
has not been selected. These images do not install an EFI bootloader, and
writing one over media containing EDK2 can destroy that firmware. No automatic
SPI/eMMC firmware update is configured. UEFI users should keep using the
separate `rawEfiImage-*` outputs and [UEFI instructions](./UEFI.md).

## 1. Flash U-Boot to SPI NOR flash

This section covers images that require separately installed firmware.
The FriendlyELEC images above already contain U-Boot for SD boot.

1. Armbian on [Orange Pi 5](https://www.armbian.com/orange-pi-5/) / [Orange Pi 5 Plus](https://www.armbian.com/orange-pi-5-plus/) as an example:
   1. download the image and flash it to a sd card first
   2. boot the board with the sd card, and then run `sudo armbian-install` to flash the uboot to the SPI NOR flash(maybe named as `MTD devices`)

For Rock 5A, we've bundled the uboot into the sdImage, so you can skip this step directly.

## 2. Flash NixOS

There're two ways to flash NixOS to the board:

1. Flash NixOS to SD card
2. Flash NixOS into SSD/eMMC

## 2.1. Flash NixOS to SD card

This is the common way to flash NixOS to the board.

Build an sdImage by `nix build`, and then flash it to a SD card using `dd`(please replace `/dev/sdX` with the correct device name of your sd card):

<!-- > **Instead of build from source, you can also download the prebuilt image from [Releases](https://github.com/gnull/nixos-rk3588/releases)**. -->
> To understand how this flakes works, please read [Cross-platform Compilation](https://nixos-and-flakes.thiscute.world/development/cross-platform-compilation).

```bash
# ==================================
# For Orange PI 5 Plus
# ==================================
# 1. Build using the qemu-emulated aarch64 environment or on Orange Pi 5 Plus itself.
# In this way, we can take advantage of the official build cache on NixOS to greatly speed up the build
# it takes about 40 minutes to build the image(mainly the kernel) on my Orange Pi 5 Plus.
# https://nixos.wiki/wiki/NixOS_on_ARM#Compiling_through_binfmt_QEMU
nix build github:gnull/nixos-rk3588#sdImage-opi5plus

# 2. Build using the cross-compilation environment
# NOTE: This will take a long time to build, as the official build cache is not available for the cross-compilation environment,
# you have to build everything from scratch.
nix build github:gnull/nixos-rk3588#sdImage-opi5plus-cross

zstdcat result/sd-image/orangepi5plus-sd-image-*.img.zst | sudo dd status=progress bs=8M of=/dev/sdX

# ==================================
# For Orange PI 5
# ==================================
nix build github:gnull/nixos-rk3588#sdImage-opi5

nix build github:gnull/nixos-rk3588#sdImage-opi5-cross # fully cross-compiled


zstdcat result/sd-image/orangepi5-sd-image-*.img.zst | sudo dd status=progress bs=8M of=/dev/sdX
```

For Rock 5A, it requires a little more work to flash the image to the sd card:

<!-- > The prebuilt image has been repaired before uploading, so you can use it directly. -->

```shell
nix build .#sdImage-rock5a
zstd -d result/sd-image/rock5a-sd-image-*.img.zst -o rock5a.img

# increase img's file size
dd if=/dev/zero bs=1M count=16 >> rock5a.img
sudo losetup --find --partscan rock5a.img

nix shell nixpkgs#parted
## rock 5a's u-boot require to use gpt partition table, and the root partition must be the first partition!
## so we need to remove all the partitions on the sd card first
## and then recreate the root partition with the same start sector as the original partition 2
START=$(sudo fdisk -l /dev/loop0 | grep /dev/loop0p2 | awk '{print $2}')
sudo parted /dev/loop0 rm 1
sudo parted /dev/loop0 rm 2
sudo parted /dev/loop0 mkpart primary ext4 ${START}s 100%

# check rootfs's status, it's broken.
sudo fsck /dev/loop0p1

# umount the image file
sudo losetup -d /dev/loop0


# flash the image to the sd card
cat rock5a.img | sudo dd status=progress bs=8M of=/dev/sdX
```

1. Insert the sd card to the board, and power on
2. Resize the root partition to the full size of the sd card.
3. Then having fun with NixOS <3.

Once the system is booted, you can use `nixos-rebuild` to update the system.

## Flash NixOS into SSD/eMMC

To flash the image into the board's eMMC / SSD, you need to flash the image into the SD card and start into NixOS first, as SSD / eMMC is not easy to remove and connect to your host.

Then, use the following command to flash the image into the board's SSD / eMMC:

```bash
# upload the sdImage to the NixOS system on the board
scp result/sd-image/orangepi5-sd-image-*.img.zst  rk@<ip-of-your-board>:~/

# login to the board via ssh or serial port
ssh rk@<ip-of-your-board>

# check all the block devices
# you should see nvme0n1(SSD)
$ lsblk
NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
mtdblock0    31:0    0    16M  0 disk
zram0       254:0    0     0B  0 disk
nvme0n1     259:0    0 238.5G  0 disk
......

# flash the image into the board's SSD
zstdcat orangepi5-sd-image-*.img.zst | sudo dd bs=4M status=progress of=/dev/nvme0n1
```

After the flash is complete, remove the SD card and reboot, and NixOS should boot from the SSD / eMMC now.
