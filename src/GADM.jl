module GADM

using DataDeps
using Logging
using ArchGDAL

"""
    dataurl(dataid)

This function takes in a dataset code of format "GADM_<Country Code>".\n
Returns the URL of the gpkg dataset of the country
"""
function dataurl(dataid)
    if occursin(r"GADM_\w+", dataid)
        provider, country_code = split(dataid, '_')
        "https://biogeo.ucdavis.edu/data/gadm3.6/gpkg/gadm36_$(country_code)_gpkg.zip"
    else
        throw(ArgumentError("invalid dataid $dataid"))
    end
end

"""
    download(dataset_code) 

Registers,downloads and returns the Absolute path of the desired dataset.
"""
function download(dataid)
    # TODO: Implement a `isvalid()` function to validate dataid

    # Registers the dataset to be used
    try
        return @datadep_str dataid
    catch KeyError
        register(
            DataDep(
                dataid,
                "GADM dataset for $dataid",
                dataurl(dataid),
                post_fetch_method=DataDeps.unpack
            )
        )
        return @datadep_str dataid
    end
end

"""
    getlevel(dataset::AbstractDataset, reqlevel::Int) 
Get layer of the desired level from the dataset
"""
function getlevel(dataset::ArchGDAL.AbstractDataset, reqlevel::Int)
    # number of layers in the dataset
    nlayers = ArchGDAL.nlayer(dataset)

    for i = 0:nlayers - 1
        layer = ArchGDAL.getlayer(dataset, i)
        layername = ArchGDAL.getname(layer)
        layerlevel = split(layername, "_")[end]
        if layerlevel == string(reqlevel)
            return layer
        end
    end

    throw(ArgumentError("valid levels for the given dataset are 0...$(nlayers - 1)"))
end

"""
    isgpkg(path)
Returns true for .gpkg files
"""
function isgpkg(path::String)
    filename, extension = splitext(path)
    extension === ".gpkg"
end

"""
    isvalidcode(code)
Returns true for ISO 3166 Alpha 3 country codes
"""
function isvalidcode(code::String)
    # only allow ISO3 country codes like IND, USA, BRA
    match(r"\b[A-Z]{3}\b", code) !== nothing
end

"""
    extractgeometry(dataset::AbstractDataset)
Returns the exterior geometry data of the dataset
"""
function extractgeometry(dataset::ArchGDAL.AbstractDataset)
    # get country level 0 layer
    country_layer = getlevel(dataset, 0)

    geom = ArchGDAL.getfeature(country_layer, 1) do feature
        ArchGDAL.getgeom(feature)        
    end

    !isnothing(geom) ? geom : throw("no geometry data found")
end

"""
    extractdataset(path)
Returns the exterior geometry data of the dataset
"""
function extractdataset(path::String)
    files = readdir(path; join=true)

    # filters only the gpkg files 
    dataset_gpkg = filter(isgpkg, files)[1]

    dataset = ArchGDAL.read(dataset_gpkg)

    !isnothing(dataset) ? dataset : throw(ArgumentError("failed to read dataset"))
end


"""
    get(country, levels...)
Returns the MULTIPOLYGON data for the requested region.\n
Input: ISO3 Country Code, and further subdivisions\n

## Examples  
  
`get("IND")` # Returns polygon of India  
`get("IND", "Uttar Pradesh")` # Returns polygon of the state Uttar Pradesh  
`get("IND", "Uttar Pradesh", "Lucknow")` # Returns polygon of district Lucknow  
"""
function get(country, levels...) 
    # only uppercase country codes are accepted
    isvalidcode(country) || throw(ArgumentError("please provide standard ISO 3 country codes"))

    dataid = "GADM_$country"

    resource_data_path = download(dataid)

    dataset = extractdataset(resource_data_path)

    # the number of varargs in levels is the required level for GADM dataset
    required_level = length(levels)

    # get layer of the required level
    level = getlevel(dataset, required_level)

    # get country level
    if required_level == 0
        return ArchGDAL.getfeature(level, 1) do feature
            ArchGDAL.getgeom(feature)
        end
    end

    nfeatures = ArchGDAL.nfeature(level)

    # Fields NAME_0, NAME_1.. of a feature contain Country's name, State's name etc.
    # ArchGDAL API doesn't allow to fetch field by it's name, field numbers are required
    # name_indexes are the field numbers of these fields which contain full names for filtering purposes
    # NAME_0 is at index 1, NAME_1 is at index 3 and so on
    name_indexes = [1, 3, 6]

    # looping on all features in the layer
    for ifeature = 1:nfeatures

        geometry = ArchGDAL.getfeature(level, ifeature) do feature

            field_name = ArchGDAL.getfield(feature, name_indexes[required_level + 1])

            # if query exists in field name, it matches and returns geometry
            if occursin(lowercase(levels[end]), lowercase(field_name))
                return ArchGDAL.getgeom(feature)
            end
        end

        # if geometry is not nothing, requried shape has been found
        if !isnothing(geometry)
            return geometry
        end
    end
    throw(ArgumentError("feature not found"))
end

end
