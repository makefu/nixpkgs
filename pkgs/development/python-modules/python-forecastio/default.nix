{ buildPythonPackage, stdenv, fetchPypi
, requests
, nose
, coverage
, responses
}:

buildPythonPackage rec {
  pname = "python-forecastio";
  version = "1.4.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0m6lf4a46pnwm5xg9dnmwslwzrpnj6d9agw570grciivbvb1ji0l";

  };

  checkInputs = [ nose coverage responses ];

  propagatedBuildInputs = [ requests responses ];

  checkPhase = ''
    nosetests --with-coverage
  '';

  meta = with stdenv.lib; {
    homepage = https://zeevgilovitz.com/python-forecast.io/;
    description = "A thin Python Wrapper for the Dark Sky (formerly forecast.io) weather API";
    license = licenses.bsd2;
    maintainers = with maintainers; [ makefu ];
  };
}
