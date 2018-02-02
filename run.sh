#!/bin/bash

# Launches IntelliJ IDEA inside a Docker container

# COBRAIMAGE=${1:-kurron/docker-intellij:latest}

DOCKER=docker
if [ -x "$(command -v nvidia-docker)" ]; then
    DOCKER=nvidia-docker
fi

MATLAB_PATH=$(dirname $(dirname $(readlink -f $(which matlab))))

echo "DOCKER cmd is $DOCKER"
echo "COBRA Image is ${COBRA_IMAGE}"
echo "MATLAB_PATH is ${MATLAB_PATH}"

DOCKER_GROUP_ID=$(cut -d: -f3 < <(getent group docker))
USER_ID=$(id -u $(whoami))
GROUP_ID=$(id -g $(whoami))
HOME_DIR=$(cut -d: -f6 < <(getent passwd ${USER_ID}))
HOME_DIR_HOST="$HOME_DIR/DevContainerHome"
#
#TODO: pass WORK_DIR and REPO_DIR (this repo) to container environment
#
WORK_DIR="$HOME_DIR/workspace"

# Need to give the container access to your windowing system
# Further reading: http://wiki.ros.org/docker/Tutorials/GUI
# and http://gernotklingler.com/blog/howto-get-hardware-accelerated-opengl-support-docker/
export DISPLAY=:0
xhost +

PULL="docker pull ${COBRA_IMAGE}"

echo ${PULL}
${PULL}

#
# Might consider using nvidia-docker instead of docker
# once support is suomehow added for Ubuntu 16.04 (manually or inherited)
#

CMD="${DOCKER} run --detach=true \
                --privileged \
                --group-add ${DOCKER_GROUP_ID} \
                --env HOME=${HOME_DIR} \
                --env DISPLAY \
                --interactive \
                --name COBRA \
                --net=host \
                --rm \
                --tty \
                --user=${USER_ID}:${GROUP_ID} \
                --volume ${MATLAB_PATH}:/opt/MATLAB \
                --volume $HOME_DIR_HOST:${HOME_DIR} \
                --volume $WORK_DIR:${WORK_DIR} \
                --volume /tmp/.X11-unix:/tmp/.X11-unix \
                --volume /var/run/docker.sock:/var/run/docker.sock \
                ${COBRA_IMAGE}"

echo $CMD
CONTAINER=$($CMD)

# Minor post-configuration
sleep 1s
docker exec --user=root $CONTAINER groupadd -g $DOCKER_GROUP_ID docker
WHO_AM_I=$(docker exec --user=$USER_ID $CONTAINER whoami)
echo "whoami is ${WHO_AM_I}"

DBUS_UUID=$(docker exec $CONTAINER /bin/bash -i -c 'dbus-uuidgen')
docker exec --user=root $CONTAINER bash -c "chmod u+w /etc/machine-id && \
    echo ${DBUS_UUID} > /etc/machine-id && \
    chmod u-w /etc/machine-id
"
docker attach $CONTAINER
