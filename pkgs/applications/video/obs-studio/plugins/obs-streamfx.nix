{ lib
, stdenv
, fetchFromGitHub
, fetchzip
, cmake
#, qtbase
, obs-studio
}:

stdenv.mkDerivation rec {
  pname = "obs-streamfx";
  version = "0.11.1";

  # src = fetchFromGitHub {
  #   owner = "Xaymar";
  #   repo = "obs-StreamFX";
  #   rev = version;
  #   sha256 = "sha256-KDzSrvmR4kt+46zyfLtu8uqLk6YOwS8GOI70b5s4vR8=";
  #   fetchSubmodules = true;
  # };

  # Temporaryily just fetch the release build
  src = fetchzip {
    url = "https://github.com/Xaymar/obs-StreamFX/releases/download/0.11.1/streamfx-ubuntu-20.04-clang-0.11.1.0-g81a96998.zip";
    hash = "sha256-PIilN9hziAX+mJO6HHKX8E7ipz/CascrmRwCfKDmpII=";
  };

  # nativeBuildInputs = [ cmake ];
  # buildInputs = [ obs-studio qtbase ];
  # dontWrapQtApps = true;
  buildInputs = [ obs-studio ];

  installPhase = ''
    mkdir -p $out/lib $out/share
    cp -r $src/StreamFX/bin/64bit $out/lib/obs-plugins
    #rm -rf $out/obs-plugins
    cp -r $src/StreamFX/data $out/share/obs
  '';

  postInstall = ''
    #rm -rf $out/obs-plugins $out/data
  '';

  meta = with lib; {
    description = "A plugin for OBS® Studio which adds many new effects, filters, sources, transitions and encoders - all for free! Be it 3D Transform, Blur, complex Masking, or even custom shaders, you'll find it all here.";
    homepage = "https://github.com/Xaymar/obs-StreamFX";
    maintainers = with maintainers; [ anoa ];
    license = licenses.gpl2Plus;
    platforms = [ "x86_64-linux" ];
  };
}
