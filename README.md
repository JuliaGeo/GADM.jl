<p align="center">
  <img src="docs/banner.png"><br>
  <a href="https://github.com/JuliaGeo/GADM.jl/actions">
    <img src="https://img.shields.io/github/actions/workflow/status/JuliaGeo/GADM.jl/CI.yml?branch=master">
  </a>
  <a href="https://codecov.io/gh/JuliaGeo/GADM.jl">
    <img src="https://codecov.io/gh/JuliaGeo/GADM.jl/branch/master/graph/badge.svg">
  </a>
  <a href="LICENSE">
    <img src="https://img.shields.io/badge/license-MIT-green.svg">
  </a>
</p>

This package provides polygons/multipolygons for all countries and their sub-divisions from the [GADM dataset](https://gadm.org/).
It fetches the data dynamically from the officially hosted database using [DataDeps.jl](https://github.com/oxinabox/DataDeps.jl).

## Installation

Get the latest stable release with Julia's package manager:

```julia
] add GADM
```

## Usage

`GADM.get` returns polygons/multipolygons, which implement the [GeoInterface](https://github.com/JuliaGeo/GeoInterface.jl):

```julia
import GADM

# GADM.get(<country>, <province/state>, <district>, <city>, ...)

# get boundary of the country India
india = GADM.get("IND")

# get boundary of the state/province Uttar Pradesh in  India
uttar = GADM.get("IND", "Uttar Pradesh")

# get boundary of the district Lucknow in Uttar Pradesh, India
lucknow = GADM.get("IND", "Uttar Pradesh", "Lucknow")
```

The option `depth=n` can be used to return a table of polygons for all subregions at depth `n`:

```julia
states = GADM.get("BRA", depth=1)
cities = GADM.get("BRA", depth=2)
```

- **Country Code** follows the ISO 3166 Alpha 3 standard, you can find the code for your country [here](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3).  
- Other regions require "approximately" official names that are at least contained (case-insensitive) in the official name.

The coordinate reference system is longitude/latitude and the WGS84 datum.

## Credits

GADM, the Database of Global Administrative Areas, is a high-resolution database of country administrative areas, with a goal of "all countries, at all levels, at any time period." The database is available in a few export formats, including shapefiles that are used in most common GIS applications.

Please read their license at https://gadm.org/license.html which is different than the MIT license of the GADM.jl package.
