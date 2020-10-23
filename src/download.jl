"""
dataurl(dataset_code)
This function takes in a dataset code of format "GADM/<country_code>"
Returns the URL of the gpkg dataset of the country
"""
function dataurl(dataset_code)

    # Splits GADM/IND to GADM, IND
    dataset_provider, country_code = split(dataset_code, "/")
    
    # Only accepts GADM Dataset Provider
    if dataset_provider != "GADM"
        error("❌ Dataset Provider $dataset_provider not supported. 💡 Please try \"GADM/<Code>\".")
    end
    
    @info "✅ fetching $country_code's data from GADM\n"

    dataset_url = "https://biogeo.ucdavis.edu/data/gadm3.6/gpkg/gadm36_$(country_code)_gpkg.zip"

    return dataset_url 
end


"""
Download(dataset_code) 
used to download the desired dataset
It generates the dataset url and registers the dependency
"""
function Download(dataset_code)

    dataset_url = dataurl(dataset_code)
    provider, country = split(dataset_code, "/")
    dataset_name = string(provider, "_", country)

    # This uses register function of DataDeps
    # It sets the dataset's name as $dataset_name
    # post_fetch_method helps to unpack the zip after downloading
    register(
        DataDep(
            dataset_name,
            "GADM dataset for "*dataset_code,
            dataset_url,
            post_fetch_method=DataDeps.unpack
        )
    )

    # Calling the readdir with @datadep_str invokes the fetch starts
    # downloading the dataset if not available
    @info "🌏 Successfully downloaded the files: ", readdir(@datadep_str dataset_name; join=true)

end
