{ stdenv, fetchgit, ... }:

stdenv.mkDerivation rec {
  name = "posix-array";
  version = "1.0.0";

  src = fetchgit {
    url = https://github.com/makefu/array.git;
    rev = "refs/tags/${version}";
    sha256 = "0yzwlhdg1rgc4p64ny7gj30l7z6vikhskhppsa2qj7s9gm2gz938";
  };

  phases = [
    "unpackPhase"
    "installPhase"
  ];

  installPhase = ''
    mkdir -p "$out/bin"
    cp -a ./array $out/bin
    rm *
  '';

  meta = {
    description = "Posix-compliant array implementation";
    url = https://github.com/makefu/array;
    license = stdenv.lib.licenses.wtfpl;
    platforms = stdenv.lib.platforms.unix;
    maintainers = with stdenv.lib.maintainers; [ makefu ];
  };


}
