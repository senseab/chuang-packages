{
  stdenv,

  jq,
  zlib-ng,
  passh,
  coreutils,
  openssh,
  which,
  xdg-terminal-exec,
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
    coreutils
    openssh
    xdg-terminal-exec
  ];

  nativeBuildInputs = [
    coreutils
    which
  ];

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/bin
    sed "/^export PATH=/s|@PATH|${coreutils}/bin:${jq}/bin:${passh}/bin:${zlib-ng.bin}/bin:${openssh}/bin:${xdg-terminal-exec}/bin|" "${bin}" > $out/bin/${pname}
    chmod +x $out/bin/${pname}

    mkdir -p $out/share/applications
    cat "${desktop}" | sed "/^Exec=/s|@EXEC|$out/bin/${pname}|" > "$out/share/applications/${pname}.desktop"

    echo "PATH: $PATH"
    which jq && which minideflate && which passh && which ssh && which xdg-terminal-exec || exit 1
  '';
}
