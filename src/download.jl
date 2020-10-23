using Printf

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