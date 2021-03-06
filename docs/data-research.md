#### Data Format

We need **GeoJSON data** about the borders.  
Precisely, [Polygon](https://tools.ietf.org/html/rfc7946#section-3.1.6) & [MultiPolygon](https://tools.ietf.org/html/rfc7946#appendix-A.4) data.

#### Resources for country data

- https://www.kaggle.com/chapagain/country-state-geo-location 

  Similar to #2

- https://github.com/johan/world.geo.json/blob/master/countries.geo.json :heavy_check_mark:

  This is the best one by far for countries data by size.

- https://www.naturalearthdata.com/downloads/10m-cultural-vectors/  

  Looks like the most trustworthy but file size is too large.

- https://github.com/stefanocudini/geojson-resources/blob/master/world.json

  Doesn't have the country codes. Instead it has Feature ID so not of much use.

- https://data.world/dgreiner/world-spatial-data :heavy_check_mark:

  [This](https://data.world/dgreiner/world-spatial-data/file/ne_50m_admin_0_countries.geojson) is the best dataset I found but the size of 50m scale map is about 4MB. It has details which we do not need like Income groups etc. But it is very exhaustive in terms of countries, regions, names, etc.
  
#### Resources for state/province datasets

 Initial research suggests that data is available only for major countries like US, Canada, India, etc. that too in a very scattered manner.  
 Looking for dataset which gives everything in one place.
 
 GADM Data is the thing to look for.
 
 - https://gadm.org/download_world.html
 
   This gives data in a csv, dbf, prj format. If figured out, this has everything for each country on a country level (0), province level (1), district level (2), subdistrict level (3).
   
   :warning: These data were extracted from the GADM database (www.gadm.org), version 2.5, July 2015. They can be used for non-commercial purposes only.  It is not allowed to redistribute these data, or use them for commercial purposes, without prior consent.
 
#### Resources for cities

1. https://github.com/drei01/geojson-world-cities :heavy_check_mark:

   36K cities, 20MB size
