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
    cp -rv "${bin}" $out/bin/${pname}
    chmod +x $out/bin/${pname}

    mkdir -p $out/share/applications
    sed "/^Version=/s|@VERSION|${version}|" "${desktop}" | sed "/^Exec=/s|@EXEC|$out/bin/${pname}|" > "$out/share/applications/${pname}.desktop"
  '';
}
