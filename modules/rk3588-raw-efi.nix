{
  config,
  lib,
  options,
  pkgs,
  modulesPath,
  nixos-generators,
  ...
}: let
  # Import raw-efi from nixos-generators
  raw-efi = nixos-generators.nixosModules.raw-efi;
in {
  # Reuse and extend the raw-efi format
  imports = [raw-efi];

  # Keep bootloader random seeds and other ESP files accessible only to root.
  fileSystems."/boot".options = [ "umask=0077" ];
}
