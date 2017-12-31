#!/bin/bash

# This script runs as root.

# Make sure kernel filesystems are mounted
mount -t proc none /proc
mount -t sysfs none /sys
mount -t devpts none /dev/pts

# This is an idempotent script for applying osgeolive to a base ubuntu install

export DEBIAN_FRONTEND=noninteractive

add-apt-repository ppa:hermlnx/xrdp -y
add-apt-repository ppa:gcpp-kalxas/jupyter -y
add-apt-repository ppa:geonode/osgeo -y
add-apt-repository ppa:osgeolive/nightly -y
add-apt-repository ppa:ubuntugis/ubuntugis-unstable -y

#echo "deb http://ppa.launchpad.net/gcpp-kalxas/jupyter/ubuntu xenial main" > /etc/apt/sources.list.d/gcpp-kalxas-ubuntu-jupyter-xenial.list
#echo "deb http://ppa.launchpad.net/geonode/osgeo/ubuntu xenial main" > /etc/apt/sources.list.d/geonode-ubuntu-osgeo-xenial.list
#echo "deb http://ppa.launchpad.net/osgeolive/nightly/ubuntu xenial main" > /etc/apt/sources.list.d/osgeolive-nightly.list
#echo "deb http://ppa.launchpad.net/ubuntugis/ubuntugis-unstable/ubuntu xenial main" > /etc/apt/sources.list.d/ubuntugis-ubuntu-ubuntugis-unstable-xenial.list

echo "deb http://qgis.org/ubuntugis-nightly xenial main" > /etc/apt/sources.list.d/qgis.list
curl -sL https://qgis.org/downloads/qgis-2017.gpg.key | apt-key add -

apt-get update

# Prepare the lubuntu base for osgeo
apt-get install -y git ubuntu-minimal ubuntu-standard openssh-server lubuntu-desktop  rsync xrdp

# Clone osgeolive
if [ ! -d /usr/local/share/gisvm ]; then
  git clone https://github.com/sofwerx/OSGeoLive /usr/local/share/gisvm
  cd /usr/local/share/gisvm/
  git checkout tags/11.0.0
fi

cd /usr/local/share/gisvm/

# Apply osgeolive scripts
export USER_NAME=manager
export USER_HOME=/home/manager
cd /usr/local/share/gisvm/bin
if ! id $USER_NAME ; then
  groupadd -g 1001 manager
  useradd -g 1001 -u 1001 -d $USER_HOME -s /bin/bash -m -c "Manager" $USER_NAME
fi
#./setup.sh release
./setup.sh nightly
if [ -L /usr/local/share/data/data ] ; then
  rm -f /usr/local/share/data/data
fi

# This borrowed from inchroot.sh from the osgeolive repo

### Base installers
./base_c.sh
./base_python.sh
./base_java.sh "$ARCH"
./base_language.sh

### Service installers
./service_apache2.sh
./base_php.sh
./service_tomcat.sh
./service_postgresql.sh
# ./service_mysql.sh

### Project installers
## C stack
./install_postgis.sh
./install_spatialite.sh
./install_osm.sh
./load_postgis.sh
./install_pgrouting.sh
./install_ossim.sh
./install_mapserver.sh
./install_tinyows.sh
./install_gmt.sh

./install_mapnik.sh
./install_otb.sh
./install_liblas.sh
./install_saga.sh
./install_grass.sh
./install_qgis.sh
./install_qgis_server.sh
./install_zoo-project.sh "$ARCH"
./install_marble.sh
./install_opencpn.sh
./install_zygrib.sh

## Python stack
./install_jupyter.sh
./install_mapproxy.sh
./install_pycsw.sh
./install_eoxserver.sh
./install_iris.sh
./install_istsos.sh
./install_mapslicer.sh

## Java stack
./install_geoserver.sh
./install_geonetwork.sh
./install_deegree.sh
./install_geomajas.sh
./install_udig.sh "$ARCH"
./install_openjump.sh
./install_gvsig.sh "$ARCH"
./install_gpsprune.sh

## Java + default tomcat
./install_52nWPS.sh
./install_52nSOS.sh
./install_ncWMS.sh

## PHP stack
./install_mapbender3.sh
./install_geomoose.sh

## more Python (GeoServer rdeps)
./install_geonode.sh
## Javascript et al
./install_openlayers.sh
./install_leaflet.sh
./install_cesium.sh
./install_R.sh
./install_rasdaman.sh

## Docs, Data and extras
./load_gisdata.sh
./install_docs.sh "$BUILD_MODE"
./install_edutools.sh

## Desktop and Housekeeping
./install_desktop.sh
./install_icons_and_menus.sh
./setdown.sh

# Update the file search index
updatedb

cat <<EOF > $USER_HOME/.xsession
#!/bin/bash
xset -dpms s off
exec /usr/bin/lxsession -s Lubuntu -e LXDE
EOF
chown ${USER_NAME}.${USER_NAME} ${USER_HOME}/.xsession
chmod +x ${USER_HOME}/.xsession

rsync -SHPaxv $USER_HOME/ /etc/skel/
chown -R root:root /etc/skel

# Clean up
apt-get clean

# Now umount (unmount) special filesystems and exit chroot
umount /proc || umount -lf /proc
umount /sys
umount /dev/pts

# Add ssh key trust
mkdir -p ${USER_HOME}/.ssh
chown ${USER_NAME}.${USER_NAME} ${USER_HOME}/.ssh
chmod 700 ${USER_HOME}/.ssh
AUTHORIZED_KEYS_FILE=$(mktemp /tmp/authorized_keys.XXXXXXXX)
(
  cat /home/ubuntu/.ssh/authorized_keys
  curl -sL https://github.com/ianblenke.keys
  curl -sL https://github.com/tabinfl.keys
  curl -sL https://github.com/ahernmikej.keys
  curl -sL https://github.com/camswx.keys
) | sort | uniq > ${AUTHORIZED_KEYS_FILE}
mv ${AUTHORIZED_KEYS_FILE} ${USER_HOME}/.ssh/authorized_keys
chown ${USER_NAME}.${USER_NAME} ${USER_HOME}/.ssh/authorized_keys
chmod 600 ${USER_HOME}/.ssh/authorized_keys

if systemctl -a | grep lightdm | grep inactive; then
  systemctl start lightdm
fi

