#!/bin/bash

BASH_COMPLETIONS="source /etc/bash_completion.d/*.bash"
eval $BASH_COMPLETIONS

export XDG_RUNTIME_DIR="/run/user/$(id -u)"

export JAVA_HOME=$(readlink -e $(type -p javac) | sed  -e 's/\/bin\/javac//g')
ln -sfT $JAVA_HOME $ENVSDIR/JDK

