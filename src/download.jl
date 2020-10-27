"""
    dataurl(dataid)

This function takes in a dataset code of format "GADM_<Country Code>".\n
Returns the URL of the gpkg dataset of the country
"""
function dataurl(dataid)
    # Only accepts GADM Dataset Provider
    if contains(dataid, "GADM")
        try
            provider, country_code = split(dataid, '_')
            "https://biogeo.ucdavis.edu/data/gadm3.6/gpkg/gadm36_$(country_code)_gpkg.zip"
        catch err
            @error "invalid dataset format, please use GADM_<country_code>."
            throw(ArgumentError("invalid dataset format"))
        end
    else
        @error "dataset provider not supported, please try \"GADM_<country_code>\"."
        throw(ArgumentError("dataset provider not supported"))
    end
end

"""
    download(dataset_code) 

Registers and downloads the desired dataset.
"""
function download(dataset_code)
    dataset_url = dataurl(dataset_code)

    # This uses register function of DataDeps package
    # Registers the dataset to be used
    register(
        DataDep(
            dataset_code,
            "GADM dataset for $dataset_code",
            dataset_url,
            post_fetch_method=DataDeps.unpack
        )
    )

    # downloading the dataset if not available
    @info "Successfully downloaded the files: ", readdir(@datadep_str dataset_code; join=true)
    return
end
