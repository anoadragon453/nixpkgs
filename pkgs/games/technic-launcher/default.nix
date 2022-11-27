{ lib, stdenv
, fetchurl
, nixosTests
, copyDesktopItems
, makeDesktopItem
, makeWrapper
, wrapGAppsHook
, gobject-introspection
, jre8
, xorg
, zlib
, nss
, nspr
, fontconfig
, pango
, cairo
, expat
, alsa-lib
, cups
, dbus
, atk
, gtk3-x11
, gtk2-x11
, gdk-pixbuf
, glib
, curl
, freetype
, libpulseaudio
, libuuid
, systemd
, flite ? null
, libXxf86vm ? null
}:
let
  desktopItem = makeDesktopItem {
    name = "technic-launcher";
    exec = "technic-launcher";
    icon = "technic-launcher";
    comment = "Technic Launcher";
    desktopName = "Technic Launcher";
    categories = [ "Game" ];
  };

  envLibPath = lib.makeLibraryPath [
    curl
    libpulseaudio
    systemd
    alsa-lib # needed for narrator
    flite # needed for narrator
    libXxf86vm # needed only for versions <1.13
  ];

  libPath = lib.makeLibraryPath ([
    alsa-lib
    atk
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    pango
    gtk3-x11
    gtk2-x11
    nspr
    nss
    stdenv.cc.cc
    zlib
    libuuid
  ] ++
  (with xorg; [
    libX11
    libxcb
    libXcomposite
    libXcursor
    libXdamage
    libXext
    libXfixes
    libXi
    libXrandr
    libXrender
    libXtst
    libXScrnSaver
  ]));
in
stdenv.mkDerivation rec {
  pname = "technic-launcher";

  version = "768";

  src = fetchurl {
    url = "https://launcher.technicpack.net/launcher4/${version}/TechnicLauncher.jar";
    hash = "sha256-e7hz8UJ2m98A1YV9Bl9G05bwbRSwzs+Us3DtFpl1kwA=";
  };

  icon = fetchurl {
    url = "https://launcher.mojang.com/download/minecraft-launcher.svg";
    sha256 = "0w8z21ml79kblv20wh5lz037g130pxkgs8ll9s3bi94zn2pbrhim";
  };

  nativeBuildInputs = [ makeWrapper wrapGAppsHook ];
  buildInputs = [ gobject-introspection ];

  sourceRoot = ".";

  dontWrapGApps = true;
  dontConfigure = true;
  dontBuild = true;
  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt

    #install -D $icon $out/share/icons/hicolor/symbolic/apps/technic-launcher.svg

    makeWrapper ${jre8}/bin/java $out/bin/technic-launcher \
      --prefix LD_LIBRARY_PATH : ${envLibPath} \
      --prefix PATH : ${lib.makeBinPath [ jre8 ]} \
      --set JAVA_HOME ${lib.getBin jre8} \
      --chdir /tmp \
      --add-flags "-jar $src" \
      "''${gappsWrapperArgs[@]}"

    runHook postInstall
  '';

  desktopItems = [ desktopItem ];

  meta = with lib; {
    description = "Technic Launcher";
    homepage = "https://www.technicpack.net";
    maintainers = with maintainers; [ anoadragon453 ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
}
