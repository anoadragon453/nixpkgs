{ stdenv, fetchurl, makeWrapper, electron_24-bin, pkgs }:

stdenv.mkDerivation rec {
  name = "calmly-writer";
  version = "2.0.54";
  src = fetchurl {
    url = "https://www.calmlywriter.com/releases/linux/targz/x64/calmly-writer-${version}.tar.gz";
    hash = "sha256-GaQRuIjbUvluABldWd6jW4XmKwkvSEtAPU4Uk3C+Hqk=";
  };

  nativeBuildInputs = [
    makeWrapper
    electron_24-bin
  ];

  sourceRoot = ".";
  installPhase = ''
    runHook preInstall
    mkdir -p $out/opt
    cp -r calmly-writer-${version}/ $out/calmly-writer
    makeWrapper ${pkgs.electron_24-bin}/bin/electron $out/bin/calmly-writer \
      --argv0 "calmly-writer" \
      --add-flags "$out/calmly-writer/resources/app.asar" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}"
    runHook postInstall
  '';

  # meta = with lib; {
  #   homepage = "https://studio-link.com";
  #   description = "Voip transfer";
  #   platforms = platforms.linux;
  # };

}