#!/bin/bash

#Author: Supun Jayathilake (supunj@gmail.com)

# Initialize locations
source ./map_locations.sh

function pre_process()
{
	#cp $SOURCE_MAP_MP $TEMP_LOC/temp0.mp

	# Map processor for mkgmap
	#echo "Preparing polish map for mkgmap...."
	#python3 $POLISH_MAP_PROCESSOR_FOR_MKGMAP/process_map/src/process_map.py $TEMP_LOC/temp0.mp $TEMP_LOC/temp1.mp 249
	#PROCESSED_SOURCE_MAP=$TEMP_LOC/temp1.mp

  cp $SOURCE_MAP_PBF $TEMP_LOC/sri-lanka-latest.osm.pbf
  #./osm_to_pg.sh

  # extract compressed maps
  echo 'Extracting large maps....'
  tar xzvf $OSM_LOC/sri_lanka_districts.osm.tar.gz -C $TEMP_LOC
  tar xzvf $OSM_LOC/sri_lanka_municipal_councils.osm.tar.gz -C $TEMP_LOC
  tar xzvf $OSM_LOC/sri_lanka_srtm_30m.osm.tar.gz -C $TEMP_LOC
}

function extract_poi()
{
        OSM_FILE_STRING=''
        for tag in "amenity" "tourism" "highway" "leisure" "historic" "natural" "railway" "shop" "public_transport" "barrier" "man_made" "landmark" "natural" "sport"
        do
                echo "Extracting POIs - $tag"
                $OSMOSIS --read-pbf file=$TEMP_LOC/sri-lanka-latest.osm.pbf --tf reject-ways --tf reject-relations --tf accept-nodes $tag=* --write-xml $TEMP_LOC/poi/sri-lanka-latest.osm_$tag.osm
                OSM_FILE_STRING="$OSM_FILE_STRING --read-xml $TEMP_LOC/poi/sri-lanka-latest.osm_$tag.osm"
        done

        echo "Merging POIs...."
        $OSMOSIS $OSM_FILE_STRING --merge --merge --merge --merge --merge --merge --merge --merge --merge --merge --merge --merge --merge --sort --write-xml $TEMP_LOC/sri-lanka-latest.osm_poi.osm

        PROCESSED_POI_MAP=$TEMP_LOC/sri-lanka-latest.osm_poi.osm
}

function prepare_type()
{
        cat $TYP_LOC/nuvi2639/header.txt $TYP_LOC/nuvi2639/polygon.txt $TYP_LOC/nuvi2639/polyline.txt $TYP_LOC/nuvi2639/poi.txt > $TEMP_LOC/typ/nuvi2639.txt
}

function merge_all()
{
	#Copy other pre-compiled maps
	#cp $OTHER_IMG_LOC/*.img $IMG_LOC

	#Combine all img files into one
	IMG_STRING=''
	for file in `find $IMG_LOC -maxdepth 1 -type f -name "*.img" -o -name "*.mdx"`
	do
		IMG_STRING="$IMG_STRING $file"
  	done

	TYP_STRING=''
	for file in `find $TEMP_LOC/typ -maxdepth 1 -type f -name "*.txt" -o -name "*.typ_no"`
	do
		TYP_STRING="$TYP_STRING $file"
  	done

	#cp $IMG_LOC/*_mdr.img $IMG_LOC/mapset

	cd $IMG_LOC/mapset
	echo 'Combining all maps....'
	$MKGMAP_JAVACMD $MKGMAP_JAVACMD_OPTIONS -jar -enableassertions $MKGMAP --code-page=1252 --keep-going --gmapsupp --tdbfile --index $IMG_STRING $TYP_STRING
}

function send_map()
{
	echo "Copying map to the device..."
	rm -rf $DEVICE_2/Garmin/*
	cp $IMG_LOC/mapset/* $DEVICE_2/Garmin
	eject $DEVICE_1
	eject $DEVICE_2
	echo "Map is copied!"
}

function cleanup()
{
	rm -rf $TEMP_LOC/*
  rm -rf $IMG_LOC/*
}

function prepare()
{
	rm -rf $IMG_LOC
	rm -rf $TEMP_LOC
  rm -rf $GPI_LOC
  mkdir -p $GPI_LOC
  mkdir -p $TEMP_LOC/poi
  mkdir -p $TEMP_LOC/typ
	mkdir -p $IMG_LOC/mapset
}


# ------------- Start -------------
prepare
pre_process
extract_poi
prepare_type

# Start building maps
cd $IMG_LOC

#echo 'Generating MP map....'
#IMG_FILE_NAME="`shuf -i 10000000-99999999 -n 1`"
#$MKGMAP_JAVACMD $MKGMAP_JAVACMD_OPTIONS $MKGMAP -c $MAP_ROOT/transport_mp.args --description=MP --mapname=$IMG_FILE_NAME --input-file=$PROCESSED_SOURCE_MAP

echo 'Generating OSM map....'
IMG_FILE_NAME="`shuf -i 10000000-99999999 -n 1`"
#echo "$MKGMAP_JAVACMD $MKGMAP_JAVACMD_OPTIONS $MKGMAP -c $MAP_ROOT/transport_osm.args --description=OSM --mapname=$IMG_FILE_NAME --coastlinefile=$OSM_LOC/sri_lanka_coastline.osm --input-file=$PBF_LOC/sri-lanka-latest.osm.pbf" > $MAP_ROOT/command.txt
$MKGMAP_JAVACMD $MKGMAP_JAVACMD_OPTIONS $MKGMAP -c $ARG_LOC/transport_osm.args --description=OSM --mapname=$IMG_FILE_NAME --style-file=$STYLE_LOC --input-file=$TEMP_LOC/sri-lanka-latest.osm.pbf

echo 'Generating POI map....'
IMG_FILE_NAME="`shuf -i 10000000-99999999 -n 1`"
$MKGMAP_JAVACMD $MKGMAP_JAVACMD_OPTIONS $MKGMAP -c $ARG_LOC/poi.args --description=POI --mapname=$IMG_FILE_NAME --style-file=$STYLE_LOC --input-file=$PROCESSED_POI_MAP

#echo 'Coastline and sea....'
IMG_FILE_NAME="`shuf -i 10000000-99999999 -n 1`"
$MKGMAP_JAVACMD $MKGMAP_JAVACMD_OPTIONS $MKGMAP -c $ARG_LOC/coastline.args --description=Sea --mapname=$IMG_FILE_NAME --coastlinefile=$OSM_LOC/sri_lanka_coastline.osm --input-file=$OSM_LOC/sri_lanka_coastline.osm

echo 'Generating districts....'
IMG_FILE_NAME="`shuf -i 10000000-99999999 -n 1`"
$MKGMAP_JAVACMD $MKGMAP_JAVACMD_OPTIONS $MKGMAP -c $ARG_LOC/admin.args --description=Districts --mapname=$IMG_FILE_NAME --input-file=$TEMP_LOC/sri_lanka_districts.osm

echo 'Generating municipal councils....'
IMG_FILE_NAME="`shuf -i 10000000-99999999 -n 1`"
$MKGMAP_JAVACMD $MKGMAP_JAVACMD_OPTIONS $MKGMAP -c $ARG_LOC/admin.args --description=Municipilities --mapname=$IMG_FILE_NAME --input-file=$TEMP_LOC/sri_lanka_municipal_councils.osm

echo 'Generating contour lines....'
IMG_FILE_NAME="`shuf -i 10000000-99999999 -n 1`"
$MKGMAP_JAVACMD $MKGMAP_JAVACMD_OPTIONS $MKGMAP -c $ARG_LOC/elevation.args --description=Contours --mapname=$IMG_FILE_NAME --style-file=$STYLE_LOC --input-file=$TEMP_LOC/sri_lanka_srtm_30m.osm

merge_all
send_map
#cleanup

# ------------- End -------------
