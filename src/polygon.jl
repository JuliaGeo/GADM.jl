"""
    getlevel(dataset::AbstractDataset, reqlevel::Int) 
Get layer of the desired level from the dataset
"""
function getlevel(dataset::ArchGDAL.AbstractDataset, reqlevel::Int)
    # number of layers in the dataset
    nlayers = ArchGDAL.nlayer(dataset)

    for i = 0:nlayers-1
        layer = ArchGDAL.getlayer(dataset, i)
        layername = ArchGDAL.getname(layer)
        layerlevel = split(layername, "_")[end]
        if layerlevel == string(reqlevel)
            return layer
        end
    end

    throw(ArgumentError("valid levels for the given dataset are 0...$(nlayers-1)"))
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
Returns true for ISO3 country codes
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
    get(code)
Returns the MULTIPOLYGON data for the requested country.\n
Input: ISO3 Country Code
"""
function get(code)
    # only uppercase country codes are accepted
    isvalidcode(code) || throw(ArgumentError("please provide standard ISO 3 country codes"))

    dataid = "GADM_$code"

    resource_data_path = download(dataid)

    dataset = extractdataset(resource_data_path)

    extractgeometry(dataset)
end
