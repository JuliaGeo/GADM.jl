module GADM

using DataDeps
using ArchGDAL
using Tables

function __init__()
    # make sure geometries are always downloaded
    # without user interaction from DataDeps.jl
    ENV["DATADEPS_ALWAYS_ACCEPT"] = true
end

"""
    isvalidcode(str)

Tells whether or not `str` is a valid
ISO 3166 Alpha 3 country code. Valid
code examples are "IND", "USA", "BRA".
"""
isvalidcode(str) = match(r"\b[A-Z]{3}\b", str) !== nothing

const API_VERSIONS = ("4.1", "4.0", "3.6", "2.8")

"""
    download(country; version="4.1")

Downloads data for `country` using DataDeps.jl and returns path.
The data is provided by the API of the [GADM](https://gadm.org) project.
It is possible to choose the API version by passing it to the
`version` keyword argument as string.
The available API versions are: 4.1 (default), 4.0, 3.6 and 2.8.
"""
function download(country; version="4.1")
    if version ∉ API_VERSIONS
        throw(ArgumentError("invalid API version"))
    end

    route = if version == "2.8"
        "https://biogeo.ucdavis.edu/data/gadm2.8/gpkg"
    else
        "https://geodata.ucdavis.edu/gadm/gadm$version/gpkg"
    end
    
    filename = if version == "2.8"
        "$(country)_adm_gpkg.zip"
    elseif version == "3.6"
        "gadm36_$(country)_gpkg.zip"
    elseif version == "4.0"
        "gadm40_$(country).gpkg"
    else
        "gadm41_$(country).gpkg"
    end

    ID = "GADM_$country"
    postfetch = version ∈ ("3.6", "2.8") ? DataDeps.unpack : identity

    try
        # if data is already on disk
        # we just return the path
        @datadep_str ID
    catch
        # otherwise we register the data
        # and download using DataDeps.jl
        register(DataDep(ID,
            "Geographic data for country $country provided by the https://gadm.org project.",
            "$route/$filename",
            post_fetch_method=postfetch
        ))
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
    getdataset(country; version="4.1")

Downloads and extracts dataset of the given country code
"""
function getdataset(country; kwargs...)
    isvalidcode(country) || throw(ArgumentError("please provide standard ISO 3 country codes"))
    dataread(download(country; kwargs...))
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
    filterlayer(data, qkeys, qvalues)

Filter layer's rows that satisfies the query params `qkeys` and `qvalues`.
"""
function filterlayer(layer, qkeys, qvalues)
    filtered = []
    for row in layer
        matchqueries = true
        for (qkey, qvalue) in zip(qkeys, qvalues)
            field = ArchGDAL.getfield(row, qkey)
            if lowercase(field) ≠ lowercase(qvalue)
                matchqueries = false
                break
            end
        end
        matchqueries && push!(filtered, row)
    end
    return Tables.columntable(filtered)
end

"""
    get(country, subregions...; depth=0, version="4.1")

Returns a Tables.jl columntable for the requested region
Geometry of the region(s) can be accessed with the key `geom`
The geometries are GeoInterface compliant Polygons/MultiPolygons.

1. country: ISO 3166 Alpha 3 country code
2. subregions: Full official names in hierarchial order (provinces, districts, etc.)
3. depth: Number of levels below the last subregion to search, default = 0

## Examples

```julia
# columntable of size 1, data of India's borders
data = get("IND")
# columntable of all states and union territories inside India
data = get("IND"; depth=1)
# columntable of all districts inside Uttar Pradesh
data = get("IND", "Uttar Pradesh"; depth=1)
```
"""
function get(country, subregions...; depth=0, kwargs...)
    data = getdataset(country; kwargs...)

    # fetch query params
    qkeys = ["NAME_$(qlevel)" for qlevel in 1:length(subregions)]
    qvalues = subregions
    
    # select layer by level
    level = length(subregions) + depth
    slayer = getlayer(data, level)
    
    # filter layer by subregions 
    slayer = filterlayer(slayer, qkeys, qvalues)
    isempty(slayer) && throw(ArgumentError("could not find required region (country $country, subregions $subregions)"))

    slayer
end

end
