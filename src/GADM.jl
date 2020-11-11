module GADM

using DataDeps
using ArchGDAL
using Logging
using Tables
using GeoInterface

"""
    isvalidcode(str)

Tells whether or not `str` is a valid
ISO 3166 Alpha 3 country code. Valid
code examples are "IND", "USA", "BRA".
"""
isvalidcode(str) = match(r"\b[A-Z]{3}\b", str) !== nothing

"""
    download(country) 

Downloads data for `country` using DataDeps.jl and returns path.
"""
function download(country)
    ID = "GADM_$country"
    try
        # if data is already on disk
        # we just return the path
        @datadep_str ID
    catch KeyError
        # otherwise we register the data
        # and download using DataDeps.jl
        register(DataDep(ID,
            "Geographic data for country $country provided by the https://gadm.org project.",
            "https://biogeo.ucdavis.edu/data/gadm3.6/gpkg/gadm36_$(country)_gpkg.zip",
            post_fetch_method=DataDeps.unpack))
        @datadep_str ID
    end
end

"""
    dataread(path)

Read data in `path` returned by [`download`](@ref).
"""
function dataread(path)
    files = readdir(path; join=true)

    isgpkg(f) = last(splitext(f)) == ".gpkg"
    gpkg = files[findfirst(isgpkg, files)]

    data = ArchGDAL.read(gpkg)

    !isnothing(data) ? data : throw(ArgumentError("failed to read data from disk"))
end

"""
    getdataset(country)

Downloads and extracts dataset of the given country code
"""
function getdataset(country)
    isvalidcode(country) || throw(ArgumentError("please provide standard ISO 3 country codes"))
    data = country |> download |> dataread
end

"""
    getlayer(data, level) 

Get layer of the desired `level` from the `data`.
"""
function getlayer(data, level)
    nlayers = ArchGDAL.nlayer(data)
    for l = 0:nlayers - 1
        layer = ArchGDAL.getlayer(data, l)
        lname = ArchGDAL.getname(layer)
        llevel = last(split(lname, "_"))
        string(level) == llevel && return layer
    end
    throw(ArgumentError("asked for level $(level), valid levels are 0-$(nlayers - 1)"))
end

"""
    get(country, subregions...; children=false)
Returns a Tables.jl columntable for the requested region
Geometry of the region(s) can be accessed with the key `geom`
The geometries are GeoInterface compliant Polygons/MultiPolygons.

1. country: ISO 3166 Alpha 3 country code  
2. subregions: Full official names in hierarchial order (provinces, districts, etc.)  
3. children: When true, function returns two columntables -> parent, children.  
Eg. when children is set true when querying just the country,
second return parameter are the states/provinces.  

## Examples  
  
```julia
# columntable of size 1, data of India's borders
data = get("IND")
# parent -> state data, children -> table of all districts inside Uttar Pradesh
parent, children = get("IND", "Uttar Pradesh"; children=true)
```
"""
function get(country, subregions...; children=false)
    data = getdataset(country)
    nlayers = ArchGDAL.nlayer(data)

    function filterlayer(layer, key, value, all=false)
        table = ArchGDAL.Table(layer)
        filtered = []
        for row in Tables.rows(table)
            field = row[Symbol(key)]
            if all || occursin(lowercase(value), lowercase(field))
                push!(filtered, row)
            end
        end
        return Tables.columntable(filtered)
    end

    # p -> parent, is the requested region
    plevel = length(subregions)
    plevel >= nlayers && throw(ArgumentError("more subregions provided than actual")) 
    pname = isempty(subregions) ? "" : last(subregions)
    player = getlayer(data, plevel)
    p = filterlayer(player, "NAME_$(plevel)", pname, iszero(plevel))
    isempty(p) && throw(ArgumentError("could not find required region"))

    !children && return p

    # c -> children, is the region 1 level lower than p
    clevel = plevel + 1
    clevel == nlayers && return (p, Tables.rowtable([]))
    clayer = getlayer(data, clevel)
    c = filterlayer(clayer, "NAME_$(plevel)", pname, iszero(plevel))

    return p, c
end

"""
    coordinates(country, subregions...)  

Returns a deep array of coordinates for the requested region.  
Input: ISO 3166 Alpha 3 Country Code, and further full official names of subdivisions  

## Example:
  
```julia
c = coordinates("VAT") # Returns a deep array of Vatican city

1-element Array{Array{Array{Float64,1},1},1}:
 [[12.455550193786678, 41.90755081176758], ..., [12.454191207885799, 41.90721130371094], [12.455550193786678, 41.90755081176758]]

c = coordinates("IND") # returns an array of coordinates of India's boundary

763-element Array{Array{Array{Array{Float64,1},1},1},1}:
 [[[93.78772736, 6.85264015], [93.7884903, 6.85257101], ...]]

 ```
"""
function coordinates(country, subregions...)
    p = get(country, subregions...)
    GeoInterface.coordinates(p.geom[1])
end

end
