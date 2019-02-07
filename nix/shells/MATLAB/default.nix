#
# TODO: consider using a shell-specific version of pathdef.m
# TODO: instead of relying on a default in Documents/MATLAB
#

with import <nixpkgs> {};
let
  matlabGcc = gcc49;
  gurobiPlatform = "linux64";
  myGurobi = (import ../../packages/gurobi/default.nix);
  cobraToolboxLocal = stdenv.mkDerivation {
    # This is a bit backwards, as it really should depend on MATLAB, once it is
    # converted into a derivation
    name = "cobraToolbox-local";
    src = fetchgit {
      url = "https://github.com/opencobra/cobratoolbox.git";
      rev = "f3fe20df5c977cf0d212e12b1763bd96d15c8760";
      sha256 = "0gqrpa1p51x0dp9m80q5b22xzfvzax2z03y0hg5zhw5qhhix08gl";
    };
    buildInputs =  [ ];
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup
      mkdir -p $out
      cp -R $src/* $out/
      # TODO: initCobraToolbox
    '';
  };
in
stdenv.mkDerivation {
  name = "impureMatlabEnv";
  inherit matlabGcc;
  buildInputs = [
    cobraToolboxLocal # TODO: MATLAB should be dep of this (swap relationship)
    matlabGcc
    makeWrapper
    myGurobi
    zlib
  ];

  libPath = stdenv.lib.makeLibraryPath [
    mesa_glu
    ncurses
    pam
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
    # export GRB_LICENSE_FILE="/opt/gurobi_CAC.lic"
    export GRB_LICENSE_FILE="$HOME/gurobi.lic"

    export COBRA_HOME=${cobraToolboxLocal.out}

    source patchMATLAB.sh

  '';
}
