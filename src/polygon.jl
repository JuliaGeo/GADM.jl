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

Examples:\n
1. `get("IND")` - Returns polygon of India
2. `get("IND", "Uttar Pradesh")` - Returns polygon of the state Uttar Pradesh
3. `get("IND", "Uttar Pradesh", "Lucknow")` - Returns polygon of district Lucknow\n
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

    # indexes of fields with entity full names
    # name of i level entity is at index at indexes[i+1]
    # Eg. Name of state (level 1) "Uttar Pradesh" will be found at index name_indexes[2], i.e. 3rd field
    name_indexes = [0, 3, 6]

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
