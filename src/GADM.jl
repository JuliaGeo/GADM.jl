module GADM

using DataDeps
using ArchGDAL
using Logging
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
    try
        # if data is already on disk
        # we just return the path
        @datadep_str country
    catch KeyError
        # otherwise we register the data
        # and download using DataDeps.jl
        register(DataDep(country,
            "Geographic data for country $country provided by the https://gadm.org project.",
            "https://biogeo.ucdavis.edu/data/gadm3.6/gpkg/gadm36_$(country)_gpkg.zip",
            post_fetch_method=DataDeps.unpack))
        @datadep_str country
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
    getlayer(data, level) 

Get layer of the desired `level` from the `data`.
"""
function getlayer(data, level)
    nlayers = ArchGDAL.nlayer(data)
    for l=0:nlayers-1
        layer = ArchGDAL.getlayer(data, l)
        lname = ArchGDAL.getname(layer)
        llevel = last(split(lname, "_"))
        string(level) == llevel && return layer
    end
    throw(ArgumentError("valid levels are 0...$(nlayers-1)"))
end

"""
    get(country, subregions...)

Returns the MULTIPOLYGON data for the requested region.

Input: ISO 3 country code, and further subdivisions.

## Examples  
  
```julia
get("IND")
get("IND", "Uttar Pradesh")
get("IND", "Uttar Pradesh", "Lucknow")
```
"""
function get(country, subregions...) 
    isvalidcode(country) || throw(ArgumentError("please provide standard ISO 3 country codes"))

    data = country |> download |> dataread

    forcemultipolygon = function(geom)
       if GeoInterface.geotype(geom) == :Polygon
        mp = ArchGDAL.createmultipolygon()
        ArchGDAL.addgeom!(mp, geom)
        return mp
       else
        return geom
       end
    end

    level = length(subregions)

    # zoom into the appropriate layer for the query
    layer = getlayer(data, level)

    # if subregions are not provided, we return the country,
    # which happens to be the first feature of the layer
    if isempty(subregions)
        return ArchGDAL.getfeature(layer, 1) do feature
            forcemultipolygon(ArchGDAL.getgeom(feature))
        end
    end

    # otherwise, we traverse the features until we encounter
    # the target subregion at the end of the list of arguments
    nfeatures = ArchGDAL.nfeature(layer)
    target = subregions[end]

    # the fields NAME_0, NAME_1, ... of a feature contain the
    # country's name, state's name, etc. However, ArchGDAL.jl
    # can only query these fields with integer indices
    indices = [1,3,6]

    for i=1:nfeatures
        geometry = ArchGDAL.getfeature(layer, i) do feature
            field = ArchGDAL.getfield(feature, indices[level+1])
            if occursin(lowercase(target), lowercase(field))
                return forcemultipolygon(ArchGDAL.getgeom(feature))
            end
        end
        isnothing(geometry) || return forcemultipolygon(geometry)
    end

    throw(ArgumentError("feature not found"))
end

"""
    coordinates(country, subregions...)  

Returns a deep array of coordinates for the requested region.  
Input: ISO 3166 Alpha 3 Country Code, and further full official names of subdivisions  

## Example:
  
```julia
julia> coordinates("VAT") # Returns a deep array of Vatican city

1-element Array{Array{Array{Array{Float64,1},1},1},1}:
 [[[12.455550193786678, 41.90755081176758], ..., [12.454191207885799, 41.90721130371094], [12.455550193786678, 41.90755081176758]]]
```
"""
coordinates(country, subregions...) = GeoInterface.coordinates(get(country, subregions...))

end
