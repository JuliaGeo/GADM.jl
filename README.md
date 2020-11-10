<p align="center">
  <img src="docs/banner.png"><br>
  <a href="https://travis-ci.com/JuliaGeo/GADM.jl">
    <img src="https://travis-ci.com/JuliaGeo/GADM.jl.svg?branch=master">
  </a>
  <a href="https://codecov.io/gh/JuliaGeo/GADM.jl">
    <img src="https://codecov.io/gh/JuliaGeo/GADM.jl/branch/master/graph/badge.svg">
  </a>
  <a href="LICENSE">
    <img src="https://img.shields.io/badge/license-MIT-green.svg">
  </a>
</p>

This package provides maps and spatial data for all countries and their sub-divisions from the [GADM dataset](https://gadm.org/). It fetches the data dynamically from the officially hosted database and provides a minimal wrapper API to get boundary data of your required region.

## Installation

Get the latest stable release with Julia's package manager:

```julia
] add GADM
```

## Usage

Given the country name and official full names of subdivisions, `get` function will  
return polygons/multipolygons which satisfy the interfaces of [GeoInterface](https://github.com/JuliaGeo/GeoInterface.jl).

```julia
import GADM

# GADM.get(<country>, <province/state>, <district>, <city>, ...)

# get boundary of the country India
bm = GADM.get("IND")

# get boundary of the state/province Uttar Pradesh in  India
bm = GADM.get("IND", "Uttar Pradesh")

# get boundary of the district Lucknow in Uttar Pradesh, India
bm = GADM.get("IND", "Uttar Pradesh", "Lucknow")
```
- **Country Code** follows the ISO 3166 Alpha 3 standard, you can find the code for your country [here](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3).  
- Other parameters require full official names.


## Credits

GADM, the Database of Global Administrative Areas, is a high-resolution database of country administrative areas, with a goal of "all countries, at all levels, at any time period." The database is available in a few export formats, including shapefiles that are used in most common GIS applications.

