{ lib
, buildPythonPackage
, fetchPypi
, libusb1
, rsa
, pycryptodome
, m2crypto
}:
buildPythonPackage rec {
  pname = "adb-homeassistant";
  version = "1.3.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "344bcaa0440501c8942fb17f27566439d1f8336c32ef1853750c995d039e58e0";
  };

  propagatedBuildInputs = [
    libusb1
    rsa
    pycryptodome
  ];


  checkInputs = [ m2crypto ];
  # disabled as the only test implemented requires m2crypto, resulting in
  #   undefined symbol: PyFile_Check
  doCheck = false;

  meta = with lib; {
    description = "A pure python implementation of the Android ADB and Fastboot protocols";
    homepage = https://github.com/google/python-adb;
    license = licenses.asl20;
    maintainers = [ maintainers.makefu ];
  };
}
