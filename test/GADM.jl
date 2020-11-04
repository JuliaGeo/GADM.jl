@testset "dataurl" begin
    # dataurl returns a string on proper formatted code GADM_<Code>
    @test isequal(GADM.dataurl("GADM_IND"), "https://biogeo.ucdavis.edu/data/gadm3.6/gpkg/gadm36_IND_gpkg.zip")

    # dataurl returns nothing on improper formatted code GADM<Code>    
    @test_throws ArgumentError GADM.dataurl("GADMIND")

    # dataurl returns nothing when code doesn't contain GADM
    @test_throws ArgumentError GADM.dataurl("IND")

    # dataurl returns nothing on empty string
    @test_throws ArgumentError GADM.dataurl("")
end

@testset "download" begin
    # dataurl returns a string on proper formatted code GADM_<Code>
    GADM.download("GADM_USA")
    @test_nowarn @datadep_str "GADM_USA"

    # download throws error on improper formatted code GADM<Code>    
    @test_throws ArgumentError GADM.download("GADMIND")

    # download throws error when code doesn't contain GADM
    @test_throws ArgumentError GADM.download("IND")

    # download throws error on empty string
    @test_throws ArgumentError GADM.download("")
end

@testset "get country polygon" begin
    # invalid country code: lowercase
    @test_throws ArgumentError GADM.get("ind")    

    # empty country code
    @test_throws ArgumentError GADM.get("")   

    # invalid code other than format [A-Z]{3}
    @test_throws ArgumentError GADM.get("IND4")   

    # valid country code
    polygon = GADM.get("IND")
    @test typeof(polygon) === ArchGDAL.IGeometry

    level1 = GADM.get("IND", "Uttar Pradesh")
    @test typeof(polygon) === ArchGDAL.IGeometry

    # throws error when query is invalid
    @test_throws ArgumentError GADM.get("IND", "Rio De Janerio")
end

@testset "isvalidcode" begin
    @test GADM.isvalidcode("ind") === false

    @test GADM.isvalidcode("") === false

    @test GADM.isvalidcode("iNd4") === false

    @test GADM.isvalidcode("IND") === true
end

@testset "isgpkg" begin
    @test GADM.isgpkg("path.gpkg") === true

    @test GADM.isgpkg("path.mp4") === false
end

@testset "extractdataset" begin
    resource_data_path = GADM.download("GADM_VAT")

    dataset = GADM.extractdataset(resource_data_path)
    @test typeof(dataset) === ArchGDAL.IDataset

    @test_throws SystemError GADM.extractdataset("")
end

@testset "extractgeometry" begin
    resource_data_path = GADM.download("GADM_VAT")
    
    dataset = GADM.extractdataset(resource_data_path)

    geometry = GADM.extractgeometry(dataset)
    @test typeof(geometry) === ArchGDAL.IGeometry
end

@testset "getlevel" begin
    resource_data_path = GADM.download("GADM_VAT")
    dataset = GADM.extractdataset(resource_data_path)

    # incorrect level
    @test_throws ArgumentError GADM.getlevel(dataset, 10)

    # correct level
    feature_layer = GADM.getlevel(dataset, 0)
    @test typeof(feature_layer) === ArchGDAL.IFeatureLayer
end
