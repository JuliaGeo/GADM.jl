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
            @error "Invalid dataset format, please use GADM_<country_code>."
        end
    else
        @error "Dataset provider not supported. Please try \"GADM_<Country Code>\"."
    end
end

"""
    download(dataset_code) 

Registers and downloads the desired dataset.
"""
function download(dataset_code)
    dataset_url = dataurl(dataset_code)

    if dataset_url === nothing
        return
    end

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
