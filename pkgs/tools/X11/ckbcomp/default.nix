{ stdenv, fetchgit, perl, xkeyboard_config }:

stdenv.mkDerivation rec {
  name = "ckbcomp-${version}";
  version = "1.131";

  src = fetchgit {
    url = "http://anonscm.debian.org/d-i/console-setup.git";
    rev = "refs/tags/${version}";
    sha256 = "0xmdnzhm1wsdpjb0wsi24xzk1xpv5h2bxgwm9f4awb7aj7wv59ma";
  };

  buildInputs = [ perl ];

  patchPhase = ''
    substituteInPlace Keyboard/ckbcomp --replace "/usr/share/X11/xkb" "${xkeyboard_config}/share/X11/xkb"
    substituteInPlace Keyboard/ckbcomp --replace "rules = 'xorg'" "rules = 'base'"
  '';

  dontBuild = true;

  installPhase = ''
    mkdir -p "$out"/bin
    cp Keyboard/ckbcomp "$out"/bin/
    mkdir -p "$out"/share/man/man1
    cp man/ckbcomp.1 "$out"/share/man/man1
  '';

  meta = with stdenv.lib; {
    description = "Compiles a XKB keyboard description to a keymap suitable for loadkeys";
    homepage = http://anonscm.debian.org/cgit/d-i/console-setup.git;
    license = licenses.gpl2Plus;
    maintainers = with stdenv.lib.maintainers; [ dezgeg ];
    platforms = platforms.linux;
  };
}
