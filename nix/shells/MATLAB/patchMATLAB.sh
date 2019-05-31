#!/bin/sh
#
# Based on https://github.com/jdreaver/NixOS-matlab/blob/master/builder.sh
#
PATCH_FILES=(
  $MATLAB_PATH/bin/glnxa64/MATLAB
  $MATLAB_PATH/bin/glnxa64/matlab_helper
  $MATLAB_PATH/bin/glnxa64/mbuildHelp
  $MATLAB_PATH/bin/glnxa64/mex
  $MATLAB_PATH/bin/glnxa64/need_softwareopengl
  $MATLAB_PATH/sys/java/jre/glnxa64/jre/bin/java
)

echo "Patching java... ($MATLAB_PATH/sys/java/jre/glnxa64/jre/bin/java)"
chmod u+rw "$MATLAB_PATH/sys/java/jre/glnxa64/jre/bin/java"
patchelf --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
  --set-rpath "$libPath:$(patchelf --print-rpath $MATLAB_PATH/sys/java/jre/glnxa64/jre/bin/java)"\
  --force-rpath "$MATLAB_PATH/sys/java/jre/glnxa64/jre/bin/java"

echo "Patching MATLAB executables..."
for f in ${PATCH_FILES[*]}; do
  chmod u+rw $f
  patchelf --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
     --set-rpath "$libPath:$(patchelf --print-rpath $f)"\
     --force-rpath $f
done

# Set the correct path to gcc
CC_FILES=(
    $MATLAB_PATH/bin/mbuildopts.sh
    $MATLAB_PATH/bin/mexopts.sh
)

for f in ${CC_FILES[*]}; do
  chmod u+rw $f
  substituteInPlace $f\
	--replace "CC='gcc'" "CC='${matlabGcc}/bin/gcc'"
done
