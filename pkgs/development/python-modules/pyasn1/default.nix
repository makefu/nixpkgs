{ stdenv, buildPythonPackage, fetchPypi, }:

buildPythonPackage rec {
  name = "${pname}-${version}";
  pname = "pyasn1";
  version = "0.4.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "05bxnr4wmrg62m4qr1pg1p3z7bhwrv74jll3k42pgxwl36kv0n6j";
  };

  meta = with stdenv.lib; {
    description = "ASN.1 tools for Python";
    homepage = http://pyasn1.sourceforge.net/;
    license = "mBSD";
    platforms = platforms.unix;  # arbitrary choice
  };
}
