{ stdenv, fetchurl, fetchpatch, cmake, mesa, libX11, xproto, libXt
, qtLib ? null }:

with stdenv.lib;

let
  os = stdenv.lib.optionalString;
  majorVersion = "5.10";
  minorVersion = "1";
  version = "${majorVersion}.${minorVersion}";
in

stdenv.mkDerivation rec {
  name = "vtk-${os (qtLib != null) "qvtk-"}${version}";
  src = fetchurl {
    url = "${meta.homepage}files/release/${majorVersion}/vtk-${version}.tar.gz";
    sha256 = "1fxxgsa7967gdphkl07lbfr6dcbq9a72z5kynlklxn7hyp0l18pi";
  };

  # https://bugzilla.redhat.com/show_bug.cgi?id=1138466
  postPatch = "sed '/^#define GL_GLEXT_LEGACY/d' -i ./Rendering/vtkOpenGL.h";

  buildInputs = [ cmake mesa libX11 xproto libXt ]
    ++ optional (qtLib != null) qtLib;

  # Shared libraries don't work, because of rpath troubles with the current
  # nixpkgs camke approach. It wants to call a binary at build time, just
  # built and requiring one of the shared objects.
  # At least, we use -fPIC for other packages to be able to use this in shared
  # objects.
  cmakeFlags = [ "-DCMAKE_C_FLAGS=-fPIC" "-DCMAKE_CXX_FLAGS=-fPIC" ]
    ++ optional (qtLib != null) [ "-DVTK_USE_QT:BOOL=ON" ];

  enableParallelBuilding = true;

  meta = {
    description = "Open source libraries for 3D computer graphics, image processing and visualization";
    homepage = http://www.vtk.org/;
    license = stdenv.lib.licenses.bsd3;
    maintainers = with stdenv.lib.maintainers; [ viric bbenoist ];
    platforms = with stdenv.lib.platforms; linux;
  };
}
