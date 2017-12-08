with import <nixpkgs> { };
let

in { cobraEnv = buildEnv {
  name = "cobra-env";
  paths = [
    ammonite
    # bash-completion # disabled, using system bash
    docker
    dotty # (Tentative Scala 3 compiler; see dottyLocal above for alternative)
    dbus # needed non-explicitly by vscode
    emacs
    git
    git-lfs
    gnupg
    less
    maven
    nodejs
    openjdk
    openssh
    re2
    rsync
    sbt
    scala
    stdenv
    tmux
    unzip
    vscode
    zlib
    
  ];
  # builder = builtins.toFile "builder.sh" ''
  #   source $stdenv/setup
  #   mkdir -p $out
  #   echo "" > $out/Done
  #   echo "Done setting up Scala environment."
  # '';
  buildInputs = [ makeWrapper ];
  # TODO: better filter, use ammonite script?:
  postBuild = ''
  # for f in $(ls -d $out/bin/* | grep "idea"); do
  #   sed -i '/IDEA_JDK/d' $f
  #   wrapProgram $f \
  #   done
  '';

};}

#######################################
#
# Refs:
# https://stackoverflow.com/questions/46165918/how-to-get-the-name-from-a-nixpkgs-derivation-in-a-nix-expression-to-be-used-by/46173041#46173041
##