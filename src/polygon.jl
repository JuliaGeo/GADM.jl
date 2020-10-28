function get_polygon(country)
    # only uppercase country codes are accepted
    dataid = "GADM_$(uppercase(country))"

    resource_data_path = download(dataid)

    @info "Resource downloaded to: $resource_data_path"

    

end