{ lib
, stdenv
, fetchFromGitHub
, autoPatchelfHook
, libdrm
}:
stdenv.mkDerivation rec {
  pname = "mali-g610-opencl";
  version = "g13p0";

  src = fetchFromGitHub {
    owner = "JeffyCN";
    repo = "mirrors";
    rev = "9b410e6c7e7f608458a81376c93480fb19faaee2";
    hash = "sha256-sXHVJ2uuNXw1gU77ZpQN1kBIzPbKYgIX4f/8VD9spXo=";
  };

  dontConfigure = true;
  dontBuild = true;
  # Preserve the vendor binary's notices and symbols.
  dontStrip = true;
  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ stdenv.cc.cc.lib libdrm ];

  preFixup = ''
    addAutoPatchelfSearchPath ${stdenv.cc.cc.lib}/aarch64-unknown-linux-gnu/lib
  '';

  installPhase = let
    library = "libmali-valhall-g610-${version}-gbm.so";
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
    description = "Vendor Mali G610 G13p0 GBM binary exposed as an OpenCL ICD";
    homepage = "https://github.com/JeffyCN/mirrors/tree/${src.rev}";
    license = {
      fullName = "ARM Mali userspace driver EULA (LES-PRE-20769)";
      url = "https://github.com/JeffyCN/mirrors/blob/${src.rev}/END_USER_LICENCE_AGREEMENT.txt";
      free = false;
      # Clause 1.1(ii) permits whole-software redistribution, or subsets
      # with Applications. Do not assume this standalone subset qualifies.
      redistributable = false;
    };
    platforms = [ "aarch64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
