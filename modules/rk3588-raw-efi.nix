{
  lib,
  nixos-generators,
  ...
}: {
  imports = [nixos-generators.nixosModules.raw-efi];

  boot.loader = {
    grub.enable = lib.mkForce false;
    systemd-boot = {
      enable = true;
      installDeviceTree = true;
    };
    efi.canTouchEfiVariables = false;
  };

  fileSystems."/boot".options = ["umask=0077"];
}
