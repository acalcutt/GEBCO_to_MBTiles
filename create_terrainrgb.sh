#!/bin/bash

# Use With https://github.com/acalcutt/rio-rgbify 

INPUT_DIR=./gebco
OUTPUT_DIR=./output
vrtfile=${OUTPUT_DIR}/gebco_terrainrgb0-8.vrt
mbtiles=${OUTPUT_DIR}/gebco_terrainrgb0-8.mbtiles
vrtfile2=${OUTPUT_DIR}/gebco_terrainrgb0-8_warp.vrt

[ -d "$OUTPUT_DIR" ] || mkdir -p $OUTPUT_DIR || { echo "error: $OUTPUT_DIR " 1>&2; exit 1; }

#rm rio/*
gdalbuildvrt -overwrite ${vrtfile} ${INPUT_DIR}/*.tif
gdalwarp -r cubic -s_srs epsg:4326 -t_srs EPSG:3857 -dstnodata 0 ${vrtfile} ${vrtfile2}
rio rgbify -b -20000 -i 0.03 --min-z 0 --max-z 8 -j 24 --format png ${vrtfile2} ${mbtiles} #Use with exaggeration of ~0.3 in maplibre terrain/hillshade

sqlite3 ${mbtiles} "UPDATE metadata SET value = 'gebco_terrainrgb_0-9' WHERE name = 'name' AND value = '';"
sqlite3 ${mbtiles} "UPDATE metadata SET value = 'GEBCO (2023) converted with rio rgbify' WHERE name = 'description';"
sqlite3 ${mbtiles} "UPDATE metadata SET value = 'png' WHERE name = 'format';"
sqlite3 ${mbtiles} "UPDATE metadata SET value = '1' WHERE name = 'version';"
sqlite3 ${mbtiles} "UPDATE metadata SET value = 'baselayer' WHERE name = 'type';"
sqlite3 ${mbtiles} "INSERT INTO metadata ('name','value') VALUES('attribution','GEBCO (2023)');"
sqlite3 ${mbtiles} "PRAGMA journal_mode=DELETE;"
