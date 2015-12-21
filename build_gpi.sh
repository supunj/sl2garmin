#!/bin/bash

#Author: Supun Jayathilake (supunj@gmail.com)

# Initialize locations
source ./map_locations.sh

cp $SOURCE_MAP_PBF $TEMP_LOC/sri-lanka-latest.osm.pbf

$OSMOSIS --read-pbf file=$TEMP_LOC/sri-lanka-latest.osm.pbf --tf reject-ways --tf reject-relations --node-key-value keyValueList="amenity.school" --write-xml file=$TEMP_LOC/school.osm
gpsbabel -i osm -f $TEMP_LOC/school.osm -o garmin_gpi,category="Schools",alerts=1,proximity=1km -F $GPI_LOC/school.gpi

$OSMOSIS --read-pbf file=$TEMP_LOC/sri-lanka-latest.osm.pbf --tf reject-ways --tf reject-relations --node-key-value keyValueList="amenity.police" --write-xml file=$TEMP_LOC/police.osm
gpsbabel -i osm -f $TEMP_LOC/police.osm -o garmin_gpi,category="Police",alerts=1,proximity=3km -F $GPI_LOC/police.gpi

$OSMOSIS --read-pbf file=$TEMP_LOC/sri-lanka-latest.osm.pbf --tf reject-ways --tf reject-relations --node-key-value keyValueList="highway.traffic_signals" --write-xml file=$TEMP_LOC/signals.osm
gpsbabel -i osm -f $TEMP_LOC/signals.osm -o garmin_gpi,category="Traffic Lights",alerts=1,proximity=0.5km -F $GPI_LOC/signals.gpi
