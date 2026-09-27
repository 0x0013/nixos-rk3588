{ config, lib, pkgs, ... }:
{
  options.hardware.mali-g610-opencl = {
    enable = lib.mkEnableOption
      "the proprietary Mali G610 OpenCL ICD (requires a compatible vendor Mali kernel driver)";
    version = lib.mkOption {
      type = lib.types.enum [ "g13p0" "g24p0" "g29p1" ];
      default = "g13p0";
      description = "Mali G610 userspace revision; g29p1 selects the OpenCL (-cl) binary.";
    };
  };

  config = lib.mkIf config.hardware.mali-g610-opencl.enable {
    assertions = [{
      assertion = pkgs.stdenv.hostPlatform.system == "aarch64-linux";
      message = "hardware.mali-g610-opencl requires aarch64-linux.";
    }];
    hardware.graphics = {
      enable = true;
      extraPackages = [ (pkgs.callPackage ../pkgs/mali-g610-opencl {
        inherit (config.hardware.mali-g610-opencl) version;
      }) ];
    };
  };
}
