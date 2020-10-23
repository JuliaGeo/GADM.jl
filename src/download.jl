using Printf
using DataDeps

# generate_dataset_url helper function
# This function takes in a dataset code of format "GADM/<country_code>"
# It returns the URL of the gpkg dataset of the country

function generate_dataset_url(dataset_code)

    # Splits GADM/IND to GADM, IND
    dataset_provider, country_code = split(dataset_code, "/")
    
    # Only accepts GADM Dataset Provider
    if dataset_provider != "GADM"
        println("❌ Dataset Provider $dataset_provider not supported.\n")
        println("💡 Please try \"GADM/<Code>\".")
        return ""
    end
    
    println("✅ fetching $country_code's data from GADM\n")

    dataset_url = @sprintf "https://biogeo.ucdavis.edu/data/gadm3.6/gpkg/gadm36_%s_gpkg.zip" country_code

    return dataset_url 

end

# register_datadep helper function registers Data Dependency in DataDeps
# It takes dataset code and dataset_url as input
# Registers and downloads the data if not available

function register_datadep(dataset_code::AbstractString, dataset_url::AbstractString)

    country_code = split(dataset_code, "/")[2]
    dataset_name = "GADM_"*country_code


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
    println("Downloaded the files: ", readdir(@datadep_str dataset_name; join=true))

end


# Download function is the main function used to download the desired dataset
# It generates the dataset url and registers the dependency

function Download(dataset_code)

    dataset_url = generate_dataset_url(dataset_code)

    if length(dataset_url) == 0
        return
    end

    register_datadep(dataset_code, dataset_url)

    println("\n🌏 Successfully downloaded the dataset!")

end
