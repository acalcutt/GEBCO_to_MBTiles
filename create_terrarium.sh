#!/bin/bash

# Use With https://github.com/acalcutt/rio-rgbify 

INPUT_DIR=./gebco
OUTPUT_DIR=./output
vrtfile=${OUTPUT_DIR}/GEBCO_2024_terrartium_z0-Z8.vrt
mbtiles=${OUTPUT_DIR}/GEBCO_2024_terrarium_z0-Z8.mbtiles
vrtfile2=${OUTPUT_DIR}/GEBCO_2024_terrarium_z0-Z8_warp.vrt

[ -d "$OUTPUT_DIR" ] || mkdir -p $OUTPUT_DIR || { echo "error: $OUTPUT_DIR " 1>&2; exit 1; }

#rm rio/*
gdalbuildvrt -overwrite ${vrtfile} ${INPUT_DIR}/*.tif
gdalwarp -r cubic -s_srs epsg:4326 -t_srs EPSG:3857 -dstnodata 0 ${vrtfile} ${vrtfile2}
rio rgbify -e terrarium --min-z 0 --max-z 8 -j 16 --format webp ${vrtfile2} ${mbtiles}

sqlite3 ${mbtiles} "UPDATE metadata SET value = 'GEBCO_2024_terrarium_z0-Z8_webp' WHERE name = 'name' AND value = '';"
sqlite3 ${mbtiles} "UPDATE metadata SET value = 'GEBCO (2024) converted with rio rgbify' WHERE name = 'description';"
sqlite3 ${mbtiles} "UPDATE metadata SET value = 'webp' WHERE name = 'format';"
sqlite3 ${mbtiles} "UPDATE metadata SET value = '1' WHERE name = 'version';"
sqlite3 ${mbtiles} "UPDATE metadata SET value = 'baselayer' WHERE name = 'type';"
sqlite3 ${mbtiles} "INSERT INTO metadata ('name','value') VALUES('attribution','GEBCO (2024)');"
sqlite3 ${mbtiles} "INSERT INTO metadata (name,value) VALUES('minzoom','0');"
sqlite3 ${mbtiles} "INSERT INTO metadata (name,value) VALUES('maxzoom','8');"
sqlite3 ${mbtiles} "INSERT INTO metadata (name,value) VALUES('bounds','-180,-90,180,90');"
sqlite3 ${mbtiles} "INSERT INTO metadata (name,value) VALUES('center','0,0,4');"
