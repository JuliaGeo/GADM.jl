# DataDeps always downloads the data if it doesn't exist
ENV["DATADEPS_ALWAYS_ACCEPT"] = true

@testset "get country polygon" begin
    # invalid country code: lowercase
    @test_throws ArgumentError Geography.get("ind")    

    # empty country code
    @test_throws ArgumentError Geography.get("")   

    # invalid code other than format [A-Z]{3}
    @test_throws ArgumentError Geography.get("IND4")   

    # valid country code
    polygon = Geography.get("IND")
    @test typeof(polygon) === ArchGDAL.IGeometry
end

@testset "isvalidcode" begin
    @test Geography.isvalidcode("ind") === false

    @test Geography.isvalidcode("") === false

    @test Geography.isvalidcode("iNd4") === false

    @test Geography.isvalidcode("IND") === true
end

@testset "isgpkg" begin
    @test Geography.isgpkg("path.gpkg") === true

    @test Geography.isgpkg("path.mp4") === false
end

@testset "getlevel" begin
    
    resource_data_path = Geography.download("GADM_USA")
    files = readdir(resource_data_path; join=true)
    dataset_gpkg = Geography.filter(Geography.isgpkg, files)[1]
    dataset = ArchGDAL.read(dataset_gpkg)

    # incorrect level
    @test_throws ArgumentError Geography.getlevel(dataset, 10)

    # correct level
    feature_layer = Geography.getlevel(dataset, 0)
    @test typeof(feature_layer) === ArchGDAL.IFeatureLayer

end