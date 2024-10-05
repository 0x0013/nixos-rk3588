{
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation {
  pname = "rkbin-nanopi6";
  version = "0.0.1";

  # https://github.com/armbian/rkbin/tree/master
  src = fetchFromGitHub {
    owner = "friendlyarm";
    repo = "rkbin";
    rev = "d04ca72fb1fdaa3771eafc18a48b6621ea397f9a";
    sha256 = "sha256-oP6GgAecXko/mKkQB3rbroT1UHrq97/MhqP6L1FztAY=";
  };

  installPhase = ''
    mkdir $out && cp rk35/rk3588* $out/
  '';
}
