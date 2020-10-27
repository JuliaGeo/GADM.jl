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

Registers and downloads the desired dataset.
"""
function download(dataid)
    # TODO: Implement a `isvalid()` function to validate dataid
    # This uses register function of DataDeps package
    # Registers the dataset to be used
    register(
        DataDep(
            dataid,
            "GADM dataset for $dataid",
            dataurl(dataid),
            post_fetch_method=DataDeps.unpack
        )
    )

    # downloading the dataset if not available
    @info "Successfully downloaded the files: ", readdir(@datadep_str dataid; join=true)
    return
end
