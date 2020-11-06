module GADM

using DataDeps
using ArchGDAL
<<<<<<< HEAD
using Logging
=======
import Meshes
import GeoInterface

"""
<<<<<<< HEAD
    getmeshespolygon(country, levels...)
Returns a Meshes.jl polygon for the requested region.\n
Input: ISO3 Country Code, and further subdivisions\n

## Examples  
  
`get("IND")` # Returns polygon of India  
`get("IND", "Uttar Pradesh")` # Returns polygon of the state Uttar Pradesh  
`get("IND", "Uttar Pradesh", "Lucknow")` # Returns polygon of district Lucknow  
"""
function getmeshespolygon(country, levels...)
    #converts [Float, Float] to Meshes Point object
    topoint2f = x -> Meshes.Point2f(x)
    # pass parameters to get
    polygon = get(country, levels...)
    # extract array of coordinates
    coordinates = GeoInterface.coordinates(polygon)

    if isa(coordinates, Array{Array{Array{Array{Float64,1},1},1},1})
        # MULTIPOLYGON
        outer = map(topoint2f, first(coordinates[1]))
        inner = []
        if length(coordinates) > 1
            for ring in coordinates[2:end]
                push!(inner, map(topoint2f, first(ring)))
            end
        end
        meshes_polygon = Meshes.Polygon(outer, inner)
        return meshes_polygon
    else
        # POLYGON
        outer = map(topoint2f, first(coordinates))
        meshes_polygon = Meshes.Polygon(outer)
        return meshes_polygon
    end
end
>>>>>>> Add getmeshespolygon

"""
    download(country) 
=======
    dataurl(dataid)
>>>>>>> Add coordinates and rename get=>polygon

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
    isvalidcode(str)

Tells whether or not `str` is a valid
ISO 3166 Alpha 3 country code. Valid
code examples are "IND", "USA", "BRA".
"""
isvalidcode(str) = match(r"\b[A-Z]{3}\b", str) !== nothing

"""
    get(country, subregions...)

Returns the MULTIPOLYGON data for the requested region.

<<<<<<< HEAD
Input: ISO 3 country code, and further subdivisions.

## Examples  
  
```julia
get("IND")
get("IND", "Uttar Pradesh")
get("IND", "Uttar Pradesh", "Lucknow")
```
"""
function get(country, subregions...) 
=======
"""
    polygon(country, levels...)
Returns a GeoInterface compliant POLYGON/MULTIPOLYGON for the requested region.\n
Input: ISO 3166 Alpha 3 Country Code, and further full official names of subdivisions\n

## Examples  
  
`polygon("IND")` # Returns polygon of India  
`polygon("IND", "Uttar Pradesh")` # Returns polygon of the state Uttar Pradesh  
`polygon("IND", "Uttar Pradesh", "Lucknow")` # Returns polygon of district Lucknow  
"""
function polygon(country, levels...) 
    # only uppercase country codes are accepted
>>>>>>> Add coordinates and rename get=>polygon
    isvalidcode(country) || throw(ArgumentError("please provide standard ISO 3 country codes"))

    data = country |> download |> dataread

    level = length(subregions)

    # zoom into the appropriate layer for the query
    layer = getlayer(data, level)

    # if subregions are not provided, we return the country,
    # which happens to be the first feature of the layer
    if isempty(subregions)
        return ArchGDAL.getfeature(layer, 1) do feature
            ArchGDAL.getgeom(feature)
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
                return ArchGDAL.getgeom(feature)
            end
        end
        isnothing(geometry) || return geometry
    end

    throw(ArgumentError("feature not found"))
end

"""
    coordinates(country, levels...)
Returns a deep array of Float64 coordinates for the requested region.\n
Input: ISO 3166 Alpha 3 Country Code, and further full official names of subdivisions\n

## Examples  
  
`coordinates("IND")` # Returns array of coordinates of India  
`coordinates("IND", "Uttar Pradesh")` # Returns array of coordinates of the state Uttar Pradesh  
`coordinates("IND", "Uttar Pradesh", "Lucknow")` # Returns array of coordinates of district Lucknow  
"""
function coordinates(country, levels...)
    p = polygon(country, levels...)
    c = GeoInterface.coordinates(p)
    p isa GeoInterface.MultiPolygon ? c : [c]
end

end
