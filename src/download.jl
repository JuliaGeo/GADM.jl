using Printf
using DataDeps

function generate_dataset_url(dataset_code)

    dataset_provider, country_code = split(dataset_code, "/")
    
    if dataset_provider != "GADM"
        println("❌ Dataset Provider $dataset_provider not supported.\n")
        println("💡 Please try \"GADM/<Code>\".")
        return ""
    end
    
    println("✅ fetching $country_code's data from GADM\n")

    dataset_url = @sprintf "https://biogeo.ucdavis.edu/data/gadm3.6/gpkg/gadm36_%s_gpkg.zip" country_code

    return dataset_url 

end

function register_datadep(dataset_code::AbstractString, dataset_url::AbstractString)

    country_code = split(dataset_code, "/")[2]
    dataset_name = "GADM_"*country_code

    register(
        DataDep(
            dataset_name,
            "GADM dataset for "*dataset_code,
            dataset_url,
            post_fetch_method=DataDeps.unpack
        )
    )

    println("Downloaded the files: ", readdir(@datadep_str dataset_name; join=true))

end


function download(dataset_code)

    dataset_url = generate_dataset_url(dataset_code)

    register_datadep(dataset_code, dataset_url)

    println("\n🌏 Successfully downloaded the dataset!")

end

download("GADM/IND")