"""
    getlevel(dataset::ArchGDAL.AbstractDataset, reqlevel::Int) 
Get layer of the desired level from the dataset
"""
function getlevel(dataset::ArchGDAL.AbstractDataset, reqlevel::Int)
    # number of layers in the dataset
    layers = ArchGDAL.nlayer(dataset)

    for i = 0:layers-1
        layer = ArchGDAL.getlayer(dataset, i)
        layername = ArchGDAL.getname(layer)
        layerlevel = split(layername, "_")[end]
        if layerlevel == string(reqlevel)
            return layer
        end
    end

    @error "valid levels for the given dataset are 0...$(layers-1)"
    return nothing
end

"""
    isgpkg(file)::Bool
Returns true for .gpkg files
"""
function isgpkg(file)::Bool
    filename, extension = splitext(file)
    extension === ".gpkg"
end

"""
    isvalidcode(code)::Bool
Returns true for ISO3 country codes
"""
function isvalidcode(code)::Bool
    # only allow ISO3 country codes like IND, USA, BRA
    match(r"\b[A-Z]{3}\b", code) !== nothing
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

    files = readdir(resource_data_path; join=true)

    # filters only the gpkg files 
    dataset_gpkg = filter(isgpkg, files)[1]

    dataset = ArchGDAL.read(dataset_gpkg)

    # get country level 0 layer
    country_layer = getlevel(dataset, 0)

    geom = ArchGDAL.getfeature(country_layer, 1) do feature
        ArchGDAL.getgeom(feature)        
    end

    !isnothing(geom) ? geom : @error "failed to extract the requested layer"

end
