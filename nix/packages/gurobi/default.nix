with import <nixpkgs> {};
let
  #TODO generify over platform using hostPlatform, etc.
  gurobiPlatform = "linux64";
  version = "9.0.3";
in  
stdenv.mkDerivation {
  pname = "gurobi";
  version = "$version";
  name = "gurobi-${version}";
  description = "A commercial convex and mixed integer optimization solver";
  src = fetchurl {
    url = "http://packages.gurobi.com/9.0/gurobi9.0.3_${gurobiPlatform}.tar.gz";
    sha256 = "4dfdb5fb1ca3bed5a230dd74b9da45d86abae934e6781d14dcfbc97c1c47dc2f";
  };
  buildInputs = [ python37 ];
  installPhase = ''
    #
    # Note: the reason files are extracted to $out/${gurobiPlatform}
    #       instead of just $out is because certain gurobi scripts
    #       depend on this.
    #
    mkdir -p $out/${gurobiPlatform}
    cp -R ${gurobiPlatform}/* $out/${gurobiPlatform}
    rm $out/${gurobiPlatform}/bin/python3.7
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
    ln -s ${python37}/bin/python3.7 $out/${gurobiPlatform}/bin/python3.7
  '';
  GUROBI_HOME = "$out/${gurobiPlatform}";
}
