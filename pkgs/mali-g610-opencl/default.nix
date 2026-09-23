{
  lib,
  stdenv,
  fetchFromGitHub,
  autoPatchelfHook,
  libdrm,
  version ? "g13p0",
}: let
  gbmSource = {
    rev = "9b410e6c7e7f608458a81376c93480fb19faaee2";
    hash = "sha256-sXHVJ2uuNXw1gU77ZpQN1kBIzPbKYgIX4f/8VD9spXo=";
  };
  variants = {
    g13p0 = gbmSource // {library = "libmali-valhall-g610-g13p0-gbm.so";};
    g24p0 = gbmSource // {library = "libmali-valhall-g610-g24p0-gbm.so";};
    g29p1 = {
      rev = "bf621d15f009509557d6b28f81427651695cac20";
      hash = "sha256-rA4KAShQ8ERGmSmu2zhBRq4OlKvGKup8N65KkzqZXu0=";
      library = "libmali-valhall-g610-g29p1-cl.so";
    };
  };
  selected = variants.${version};
in
  stdenv.mkDerivation rec {
    pname = "mali-g610-opencl";
    inherit version;

    src = fetchFromGitHub {
      owner = "JeffyCN";
      repo = "mirrors";
      inherit (selected) rev hash;
    };

    dontConfigure = true;
    dontBuild = true;
    # Preserve the vendor binary's notices and symbols.
    dontStrip = true;
    nativeBuildInputs = [autoPatchelfHook];
    buildInputs = [stdenv.cc.cc.lib libdrm];

    preFixup = ''
      addAutoPatchelfSearchPath ${stdenv.cc.cc.lib}/aarch64-unknown-linux-gnu/lib
    '';

    installPhase = let
      inherit (selected) library;
    in ''
      runHook preInstall
      install -Dm755 "$src/lib/aarch64-linux-gnu/${library}" "$out/lib/${library}"
      mkdir -p "$out/etc/OpenCL/vendors"
      echo "$out/lib/${library}" > "$out/etc/OpenCL/vendors/mali.icd"
      install -Dm644 "$src/END_USER_LICENCE_AGREEMENT.txt" \
        "$out/share/licenses/${pname}/END_USER_LICENCE_AGREEMENT.txt"
      install -Dm644 "$src/debian/copyright" "$out/share/licenses/${pname}/copyright"
      runHook postInstall
    '';

    meta = {
      description = "Vendor Mali G610 ${version} OpenCL ICD";
      homepage = "https://github.com/JeffyCN/mirrors/tree/${src.rev}";
      license = {
        fullName = "ARM Mali userspace driver EULA (LES-PRE-20769)";
        url = "https://github.com/JeffyCN/mirrors/blob/${src.rev}/END_USER_LICENCE_AGREEMENT.txt";
        free = false;
        # Clause 1.1(ii) permits whole-software redistribution, or subsets
        # with Applications. Do not assume this standalone subset qualifies.
        redistributable = false;
      };
      platforms = ["aarch64-linux"];
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  }
