{
  stdenv,
  stdenvNoCC,
  fetchFromGitHub,
  autoPatchelfHook,
  libdrm,
}: let
  src = fetchFromGitHub {
    owner = "JeffyCN";
    repo = "mirrors";
    rev = "9b410e6c7e7f608458a81376c93480fb19faaee2";
    hash = "sha256-sXHVJ2uuNXw1gU77ZpQN1kBIzPbKYgIX4f/8VD9spXo=";
  };
in {
  # Not using this as g25p0 is included in armbian kernel
  mali-firmware-g24p0-01eac0 = stdenvNoCC.mkDerivation {
    pname = "mali-g610-firmware";
    version = "g24p0-01eac0";
    dontBuild = true;
    dontFixup = true;
    compressFirmware = false;

    inherit src;

    buildCommand = ''
      runHook preInstall

      mkdir -p $out/lib/firmware
      install --mode=755 $src/firmware/g610/mali_csffw.bin $out/lib/firmware/

      runHook postInstall
    '';
  };

  # this works for jellyfin tone-mapping OpenCL
  libmali-valhall-g610-g13p0-gbm = stdenv.mkDerivation rec {
    pname = "libmali-valhall-g610";
    version = "g13p0";
    variant = "gbm";
    dontConfigure = true;

    inherit src;

    nativeBuildInputs = [ autoPatchelfHook ];
    buildInputs = [ stdenv.cc.cc.lib libdrm ];

    preBuild = ''
      addAutoPatchelfSearchPath ${stdenv.cc.cc.lib}/aarch64-unknown-linux-gnu/lib
    '';

    installPhase = let
      libmaliFileName = "${pname}-${version}-${variant}.so";
    in ''
      runHook preInstall

      mkdir -p $out/lib
      mkdir -p $out/etc/OpenCL/vendors

      install --mode=755 $src/lib/aarch64-linux-gnu/${libmaliFileName} $out/lib
      echo $out/lib/${libmaliFileName} > $out/etc/OpenCL/vendors/mali.icd

      runHook postInstall
    '';
  };
}
