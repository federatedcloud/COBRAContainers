#
# TODO: consider using a shell-specific version of pathdef.m
# TODO: instead of relying on a default in Documents/MATLAB
#

with import <nixpkgs> {};
let
  matlabGcc = gcc49;
  gurobiPlatform = "linux64";
  myGurobi = (import ../../packages/gurobi/default.nix);
in
stdenv.mkDerivation {
  name = "impureMatlabEnv";
  inherit matlabGcc;
  buildInputs = [
    matlabGcc
    makeWrapper
    zlib
  ];

  libPath = stdenv.lib.makeLibraryPath [
    mesa_glu
    pam
    ncurses
    xorg.libxcb
    xorg.libXi
    xorg.libXext
    xorg.libXmu
    xorg.libXp
    xorg.libXpm
    xorg.libXrandr
    xorg.libXrender
    xorg.libXt
    xorg.libXtst
    xorg.libXxf86vm
    xorg.libX11
    zlib
  ];
  src = null;
  shellHook = ''
    export MATLAB_VERSION=R2017a
    export MATLAB_PATH=/opt/MATLAB/$MATLAB_VERSION
    export PATH=$PATH:$MATLAB_PATH/bin
    export GUROBI_HOME="${myGurobi.out}/${gurobiPlatform}"
    export GUROBI_PATH="${myGurobi.out}/${gurobiPlatform}"
    export GRB_LICENSE_FILE="$HOME/gurobi_CAC.lic"

    source patchMATLAB.sh

  '';
}
