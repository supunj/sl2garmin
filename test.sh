#!/bin/bash

# Initialize locations
source ./map_locations.sh

#cp $SOURCE_MAP_PBF $TEMP_LOC/sri-lanka-latest.osm.pbf

#$OSMOSIS --read-pbf file=$TEMP_LOC/sri-lanka-latest.osm.pbf --write-xml $TEMP_LOC/sri-lanka-latest.osm

#$OSMOSIS --read-pbf file=$TEMP_LOC/sri-lanka-latest.osm.pbf --tf reject-ways natural=coastline --tf accept-nodes --used-node --write-xml $TEMP_LOC/sri-lanka-latest.osm_no_coast.osm

#$OSMOSIS --read-pbf file=$TEMP_LOC/sri-lanka-latest.osm.pbf --tf reject-ways --tf reject-relations --tf accept-nodes --used-node --write-xml $TEMP_LOC/sri-lanka-latest_poi.osm

#$OSMOSIS035 --read-xml-0.5 enableDateParsing=no file=$OSM_LOC/sri_lanka_coastline.osm --migrate --sort --write-xml $TEMP_LOC/sri_lanka_coastline.osm

$OSMOSIS035 --read-xml-0.5 enableDateParsing=no file=$OSM_LOC/sri_lanka_srtm_30m.osm --migrate --sort --write-xml $OSM_LOC/sri_lanka_srtm_30m_v6.osm

$OSMOSIS --read-xml file=$OSM_LOC/sri_lanka_srtm_30m_v6.osm --write-pbf $OSM_LOC/sri_lanka_srtm_30m_v6.osm.pbf
