FROM ubuntu:18.04

#ARG nixuser
ENV nixuser cobra
ENV ENVSDIR /nixenv/$nixuser
ENV HOME /home/$nixuser
ENV HOME_TEMPLATE /template/$nixuser
WORKDIR $ENVSDIR

MAINTAINER Brandon Barker <brandon.barker@cornell.edu>

RUN adduser --disabled-password --gecos "" $nixuser && \
  echo "$nixuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
  mkdir -m 0755 /nix && \
  mkdir -p $HOME_TEMPLATE && \
  mkdir -p /run/user/$(id -u $nixuser) && chown $nixuser:$nixuser /run/user/$(id -u $nixuser) && \
  chown -R $nixuser:$nixuser /nix $ENVSDIR $HOME $HOME_TEMPLATE
  
RUN echo "nameserver 8.8.8.8" | tee /etc/resolv.conf > /dev/null && \
  apt-get update -y && apt-get install -y --no-install-recommends bzip2 ca-certificates \
  curl wget && \
  apt-get clean && \
  wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -P /etc/bash_completion.d/

#
# UTF-8 by default
#
RUN apt-get install locales && \
  locale-gen en_US.UTF-8 
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN echo "nixbld:x:30000:nixbld1,nixbld2,nixbld3,nixbld4,nixbld5,nixbld6,nixbld7,nixbld8,nixbld9,nixbld10,nixbld11,nixbld12,nixbld13,nixbld14,nixbld15,nixbld16,nixbld17,nixbld18,nixbld19,nixbld20,nixbld21,nixbld22,nixbld23,nixbld24,nixbld25,nixbld26,nixbld27,nixbld28,nixbld29,nixbld30" >> /etc/group \
  && for i in $(seq 1 30); do echo "nixbld$i:x:$((30000 + $i)):30000:::" >> /etc/passwd; done 

COPY ./config.nix $HOME/.config/nixpkgs/
COPY ./cobra-default.nix $ENVSDIR/
RUN chown -R $nixuser:$nixuser $ENVSDIR $HOME

#
# Install a few additional Ubuntu packages that are tedious to do from Nix
#
RUN apt-get install -y --no-install-recommends x11-apps && \
  apt-get clean

USER $nixuser

RUN wget -O- http://nixos.org/releases/nix/nix-2.0.4/nix-2.0.4-x86_64-linux.tar.bz2 | bzcat - | tar xf - \
    && USER=$nixuser HOME=$ENVSDIR sh nix-*-x86_64-linux/install


#
# This broke at some point, so trying system certs for now:
# GIT_SSL_CAINFO=$ENVSDIR/.nix-profile/etc/ssl/certs/ca-bundle.crt \
# 
ENV \
    PATH=$ENVSDIR/.nix-profile/bin:$ENVSDIR/.nix-profile/sbin:/bin:/sbin:/usr/bin:/usr/sbin \
    SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt \
    GIT_SSL_CAINFO=/etc/ssl/certs/ca-bundle.crt \
    NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt \
    NIX_PATH=/nix/var/nix/profiles/per-user/$ENVSDIR/channels/
  
ENV nixenv ". $ENVSDIR/.nix-profile/etc/profile.d/nix.sh"

RUN $nixenv && nix-channel --add http://nixos.org/channels/nixpkgs-unstable nixpkgs && \
  nix-channel --add http://nixos.org/channels/nixos-unstable nixos
  
RUN $nixenv && SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt nix-channel --update

#
# Initialize environment a bit for faster container spinup/use later
#
RUN $nixenv && cd /tmp && nix-env --fallback -if $ENVSDIR/cobra-default.nix && printf 'exit\n' | sbt -Dsbt.global.base=.sbt -Dsbt.boot.directory=.sbt -Dsbt.ivy.home=.ivy2 && \
  rsync -a $HOME/ $HOME_TEMPLATE


#Copy this last to prevent rebuilds when changes occur in entrypoint:
COPY ./entrypoint $ENVSDIR/
USER root
RUN chown $nixuser:$nixuser $ENVSDIR/entrypoint
USER $nixuser

CMD ["./entrypoint"]

