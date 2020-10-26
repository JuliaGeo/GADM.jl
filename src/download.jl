"""
    dataurl(dataset_code)

This function takes in a dataset code of format "GADM/<country_code>"
Returns the URL of the gpkg dataset of the country
"""    

function dataurl(dataset_provider, country_code)

    # Only accepts GADM Dataset Provider
    if dataset_provider != "GADM"
        @error "Dataset Provider $dataset_provider not supported. Please try \"GADM/<Code>\"."
    end
    
    @info "Fetching $country_code's data from GADM...\n"

    "https://biogeo.ucdavis.edu/data/gadm3.6/gpkg/gadm36_$country_code_gpkg.zip"
end

"""
    download(dataset_code) 

used to download the desired dataset
It generates the dataset url and registers the dependency
"""

function download(dataset_code)

    dataset_provider, country_code = split(dataset_code, "/")

    dataset_url = dataurl(dataset_provider, country_code)

    dataset_name = string(provider, "_", country)

    # This uses register function of DataDeps package
    # Registers the dataset to be used
    register(
        DataDep(
            dataset_name,
            "GADM dataset for $dataset_code",
            dataset_url,
            post_fetch_method=DataDeps.unpack
        )
    )

    # downloading the dataset if not available
    @info "Successfully downloaded the files: ", readdir(@datadep_str dataset_name; join=true)
end
