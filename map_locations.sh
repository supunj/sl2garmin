#!/bin/bash

#Author: Supun Jayathilake (supunj@gmail.com)

# Content locations
MAP_ROOT=$(dirname $(readlink -f $0))
TEMP_LOC=$MAP_ROOT/tmp
STYLE_LOC=$MAP_ROOT/resources/style
TYP_LOC=$MAP_ROOT/resources/typ
MP_LOC=$MAP_ROOT/maps/mp
OSM_LOC=$MAP_ROOT/maps/osm
IMG_LOC=$MAP_ROOT/garmin
OTHER_IMG_LOC=$MAP_ROOT/maps/img
PBF_LOC=$MAP_ROOT/maps/pbf
GPI_LOC=$MAP_ROOT/gpi
#ICON_LOC=$MAP_ROOT/resources/icon
ARG_LOC=$MAP_ROOT/arg
PG_LOC=$MAP_ROOT/pg

# Tools
MKGMAP=$MAP_ROOT/tools/mkgmap/dist/mkgmap.jar
#MKGMAP_ALT=$MAP_TOOLS_LOC/mkgmap/dist/mkgmap.jars
OSMOSIS_LOC=$MAP_ROOT/tools/osmosis/package
OSMOSIS=$OSMOSIS_LOC/bin/osmosis

# Devices
DEVICE_1=/media/$USER/GARMIN
DEVICE_2=/media/$USER/GARMIN_SD

# Files
COASTLINE=$OSM_LOC/sri_lanka_coastline.osm
SOURCE_MAP_MP=$MP_LOC/sri_lanka_base.mp
SOURCE_MAP_PBF=$PBF_LOC/sri-lanka-latest.osm.pbf

export MKGMAP_JAVACMD=/usr/bin/java
export MKGMAP_JAVACMD_OPTIONS="-Xmx2048M -jar -enableassertions"
