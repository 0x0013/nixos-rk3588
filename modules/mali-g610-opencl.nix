{ config, lib, pkgs, ... }:
{
  options.hardware.mali-g610-opencl.enable = lib.mkEnableOption
    "the proprietary Mali G610 OpenCL ICD (requires a compatible vendor Mali kernel driver)";

  config = lib.mkIf config.hardware.mali-g610-opencl.enable {
    assertions = [{
      assertion = pkgs.stdenv.hostPlatform.system == "aarch64-linux";
      message = "hardware.mali-g610-opencl requires aarch64-linux.";
    }];
    hardware.graphics = {
      enable = true;
      extraPackages = [ (pkgs.callPackage ../pkgs/mali-g610-opencl { }) ];
    };
  };
}
