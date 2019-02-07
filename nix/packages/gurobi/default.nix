with import <nixpkgs> {};
let
  #TODO generify over platform using hostPlatform, etc.
  gurobiPlatform = "linux64";
  version = "7.5.1";
in  
stdenv.mkDerivation {
  pname = "gurobi";
  version = "$version";
  name = "gurobi-${version}";
  description = "A commercial convex and mixed integer optimization solver";
  src = fetchurl {
    url = "http://packages.gurobi.com/7.5/gurobi7.5.1_${gurobiPlatform}.tar.gz";
    sha256 = "7f5c8b0c3d3600ab7a1898f43e238a9d9a32ac1206f2917fb60be9bbb76111b6";
  };
  buildInputs = [ python27 ];
  installPhase = ''
    #
    # Note: the reason files are extracted to $out/${gurobiPlatform}
    #       instead of just $out is because certain gurobi scripts
    #       depend on this.
    #
    mkdir -p $out/${gurobiPlatform}
    cp -R ${gurobiPlatform}/* $out/${gurobiPlatform}
    rm $out/${gurobiPlatform}/bin/python2.7
    for exfi in $out/${gurobiPlatform}/bin/* ; do
      echo "EXFI is $exfi"
      if isELF "$exfi"; then
        patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
          --set-rpath "$libPath:$(patchelf --print-rpath $exfi)" \
	  --force-rpath $exfi
      fi;
    done
    ln -s $out/${gurobiPlatform}/bin $out/bin
    ln -s $out/${gurobiPlatform}/lib $out/lib
    ln -s ${python27}/bin/python2.7 $out/${gurobiPlatform}/bin/python2.7
  '';
  GUROBI_HOME = "$out/${gurobiPlatform}";
}
