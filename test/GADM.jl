@testset "dataurl" begin
    # dataurl returns a string on proper formatted code GADM_<Code>
    @test isequal(Geography.dataurl("GADM_IND"), "https://biogeo.ucdavis.edu/data/gadm3.6/gpkg/gadm36_IND_gpkg.zip")

    # dataurl returns nothing on improper formatted code GADM<Code>    
    @test_throws ArgumentError Geography.dataurl("GADMIND")

    # dataurl returns nothing when code doesn't contain GADM
    @test_throws ArgumentError Geography.dataurl("IND")

    # dataurl returns nothing on empty string
    @test_throws ArgumentError Geography.dataurl("")
end

@testset "download" begin
    # dataurl returns a string on proper formatted code GADM_<Code>
    Geography.download("GADM_USA")
    @test_nowarn @datadep_str "GADM_USA"

    # download throws error on improper formatted code GADM<Code>    
    @test_throws ArgumentError Geography.download("GADMIND")

    # download throws error when code doesn't contain GADM
    @test_throws ArgumentError Geography.download("IND")

    # download throws error on empty string
    @test_throws ArgumentError Geography.download("")
end

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

    level1 = Geography.get("IND", "Uttar Pradesh")
    @test typeof(polygon) === ArchGDAL.IGeometry

    # throws error when query is invalid
    @test_throws ArgumentError Geography.get("IND", "Rio De Janerio")
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

@testset "extractdataset" begin
    resource_data_path = Geography.download("GADM_VAT")

    dataset = Geography.extractdataset(resource_data_path)
    @test typeof(dataset) === ArchGDAL.IDataset

    @test_throws SystemError Geography.extractdataset("")
end

@testset "extractgeometry" begin
    resource_data_path = Geography.download("GADM_VAT")
    
    dataset = Geography.extractdataset(resource_data_path)

    geometry = Geography.extractgeometry(dataset)
    @test typeof(geometry) === ArchGDAL.IGeometry
end

@testset "getlevel" begin
    resource_data_path = Geography.download("GADM_VAT")
    dataset = Geography.extractdataset(resource_data_path)

    # incorrect level
    @test_throws ArgumentError Geography.getlevel(dataset, 10)

    # correct level
    feature_layer = Geography.getlevel(dataset, 0)
    @test typeof(feature_layer) === ArchGDAL.IFeatureLayer
end
