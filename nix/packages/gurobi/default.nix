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
    mkdir -p $out
    cp -R ${gurobiPlatform}/* $out/
    echo "CAT DYN LINK START"
    cat $NIX_CC/nix-support/dynamic-linker
    echo "CAT DYN LINK END"
    for exfi in $out/bin ; do
      if [[ -x "$exfi" && -f "$exfi" && ! -L "$exfi" ]]; then
        patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
          --set-rpath "$libPath:$(patchelf --print-rpath $exfi)" \
	  --force-rpath $exfi
      fi;
    done
    rm $out/bin/python2.7
    ln -s ${python27}/bin/python2.7 $out/bin/python2.7
  '';
  GUROBI_HOME = "$out";
}
