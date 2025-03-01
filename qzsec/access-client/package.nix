{
  stdenv,

  jq,
  zlib-ng,
  passh,
  ...
}:
let
  bin = ./access-client;
  desktop = ./access-client.desktop;
in
stdenv.mkDerivation rec {
  pname = "access-client";
  version = "1.0.0";

  buildInputs = [
    jq
    zlib-ng
    passh
  ];

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/bin
    cp -rv "${bin}" $out/bin
    chmod +x $out/bin/*

    mkdir -p $out/share/applications
    cp -rv "${desktop}" $out/share/applications
  '';
}
