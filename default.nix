#
# TODO: consider using a shell-specific version of pathdef.m
# TODO: instead of relying on a default in Documents/MATLAB
#

with import <nixpkgs> {};
let
  gurobiPlatform = "linux64";
  myGurobi = (import nix/packages/gurobi/default.nix);
  myMatlab = (import nix/packages/haskell-matlab/default.nix);
  cobraToolboxLocal = stdenv.mkDerivation {
    # This is a bit backwards, as it really should depend on MATLAB, once it is
    # converted into a derivation
    name = "cobraToolbox-local";
    src = fetchgit {
      url = "https://github.com/opencobra/cobratoolbox.git";
      rev = "92518352da3dc1f63b7ef781345786f5cf73034c";
      sha256 = "00s94bnjggq2bz4q8fqfwkj65b0nkzqqxp1557ld8iab65dfsvr6";
      deepClone = true;
    };
    buildInputs =  [git];
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup
      mkdir -p $out
      cp -R $src/* $out/
      cd $out/
      rm -fr $out/.git
      # TODO: initCobraToolbox
    '';
  };
in
haskell.lib.buildStackProject {
  name = "cobraMatlabHaskellEnv";
  dontUnpack = true;
  buildInputs = myMatlab.buildInputs ++ [
    cobraToolboxLocal # TODO: MATLAB should be dep of this (swap relationship)
    makeWrapper
    myGurobi
    # myMatlab

    # needed to run MATLAB (even without display):
    ncurses6
    pam
    xorg.libX11
    xorg.libXext
    xorg.libXt
    xorg.libxcb

    zlib
  ];
  libPath = myMatlab.libPath;
  # buildPhase = "";
  installPhase = "";
  src = null;
  shellHook = ''
    # Copied or modified from MATLAB's default.nix:
    export MATLAB_PATH=${myMatlab.matlabPath}
    export PATH=$PATH:$MATLAB_PATH/bin
    source ${./nix/shells/MATLAB/patchMATLAB.sh}

    # Access utilities install by stack, such as haskell-matlab programs
    export PATH=$HOME/.local/bin:$PATH

    export GUROBI_HOME="${myGurobi.out}/${gurobiPlatform}"
    export GUROBI_PATH="${myGurobi.out}/${gurobiPlatform}"

    export GRB_LICENSE_FILE="/opt/gurobi.lic"
    #
    # The single-user license files somewhat annoyingly keeps track of how many
    # sockets are present, so we need a different license and license file
    # for each case:
    # export GRB_LICENSE_FILE="$HOME/gurobi_4_sockets.lic"
    #
    # This is not an issue for the multi-site license above (gurobi_CAC.lic)
    #

    export COBRA_HOME=${cobraToolboxLocal.out}
  '';
}
