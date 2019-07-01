#!/bin/sh
#
# Install script for chaperone inside a Docker container.
#

# Packages that are only used to build the container. These will be
# removed once we're done.
BUILD_PACKAGES="python3-dev"

# Packages required to serve the website and run the services.
# We have to keep the python3 packages around in order to run
# chaperone (installed via pip).
PACKAGES="python3-pip python3-setuptools python3-wheel"

# The default bitnami/minideb image defines an 'install_packages'
# command which is just a convenient helper. Define our own in
# case we are using some other Debian image.
if [ "x$(which install_packages)" = "x" ]; then
    install_packages() {
        env DEBIAN_FRONTEND=noninteractive apt-get install -qy -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" --no-install-recommends "$@"
    }
fi

die() {
    echo "ERROR: $*" >&2
    exit 1
}

set -x

# Add backports
echo "deb http://deb.debian.org/debian stretch-backports main" >> /etc/apt/sources.list
apt-get clean && apt-get update

# Install required packages
install_packages ${BUILD_PACKAGES} ${PACKAGES} \
    || die "could not install packages"

# Install Chaperone (minimalistic init service).
pip3 install chaperone \
    || die "could not install chaperone"
rm -fr /root/.cache/pip

# Set the localtime to Europe/Oslo
mv /etc/localtime /etc/localtime.utc
ln -s /usr/share/zoneinfo/Europe/Oslo /etc/localtime

# Users of this base image should provide their own Chaperone config.
#cp /tmp/conf/chaperone.conf /etc/chaperone.d/chaperone.conf

# Remove packages used for installation.
apt-get remove -y --purge ${BUILD_PACKAGES}
apt-get autoremove -y
apt-get clean
rm -fr /var/lib/apt/lists/*

