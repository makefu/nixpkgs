{ stdenv, buildPythonPackage, fetchFromGitHub, python

, pbr, testtools, testresources, testrepository
, requests-mock, fixtures, openssl, oslotest, pep8

, oslo-serialization, oslo-config, oslo-i18n, oslo-utils
, Babel, prettytable, requests, six, iso8601, stevedore
, netaddr, debtcollector, bandit, webob, mock, pycrypto
, keystoneauth1
}:

buildPythonPackage rec {
  pname = "keystoneclient";
  version = "3.14.0";

  src = fetchFromGitHub {
    owner = "openstack";
    repo = "python-keystoneclient";
    rev = version;
    sha256 = "01pc6mrh046idj2gd6jj5bf0cwwv5q6dc9pyfbvdhx29g1m4vag0";
  };

  PBR_VERSION = "${version}";

  checkInputs = [
    pbr testtools testresources testrepository requests-mock fixtures openssl
    oslotest pep8
  ];
  propagatedBuildInputs = [
    oslo-serialization oslo-config oslo-i18n oslo-utils
    Babel prettytable requests six iso8601 stevedore
    netaddr debtcollector bandit webob mock pycrypto
    keystoneauth1
  ];

  postPatch = ''
    sed -i 's@python@${python.interpreter}@' .testr.conf
    sed -ie '/argparse/d' requirements.txt
    '';

  doCheck = false; # The checkPhase below is broken

  checkPhase = ''
    patchShebangs run_tests.sh
    ./run_tests.sh
  '';

  meta = with stdenv.lib; {
    homepage = https://github.com/openstack/python-novaclient/;
    description = "Client library and command line tool for the OpenStack Nova API";
    license = licenses.asl20;
    platforms = platforms.linux;
  };
}
