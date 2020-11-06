@testset "isvalidcode" begin
    @test GADM.isvalidcode("IND")
    @test GADM.isvalidcode("BRA")
    @test GADM.isvalidcode("USA")
    @test !GADM.isvalidcode("ind")
    @test !GADM.isvalidcode("")
    @test !GADM.isvalidcode("iNd4")
end

@testset "download" begin
    # test successful download
    GADM.download("USA")
    @test_nowarn @datadep_str "USA"
end

@testset "dataread" begin
    path = GADM.download("IND")
    data = GADM.dataread(path)
    @test typeof(data) === ArchGDAL.IDataset
end

@testset "getlayer" begin
    path = GADM.download("IND")
    data = GADM.dataread(path)

    # incorrect level
    @test_throws ArgumentError GADM.getlayer(data, 10)

    # correct level
    layer = GADM.getlayer(data, 0)
    @test typeof(layer) === ArchGDAL.IFeatureLayer
end

@testset "get" begin
    # invalid country codes
    @test_throws ArgumentError GADM.get("ind")    
    @test_throws ArgumentError GADM.get("")   
    @test_throws ArgumentError GADM.get("IND4")   

    # valid country codes
    polygon = GADM.get("IND")
    @test typeof(polygon) == ArchGDAL.IGeometry

    polygon = GADM.get("IND", "Uttar Pradesh")
    @test typeof(polygon) == ArchGDAL.IGeometry

    # throws error when query is invalid
    @test_throws ArgumentError GADM.get("IND", "Rio De Janerio")
end

@testset "basic" begin
    geom = GADM.get("VAT")

    bounds = ArchGDAL.envelope(geom)

    bounds_arr = [bounds.MinX, bounds.MaxX, bounds.MinY, bounds.MaxY]

    # Vatican City bounding boxes lat min 41.9002044 lat max 41.9073912 lon min 12.4457442 lon max 12.4583653
    bounds_actual = [12.4457442, 12.4583653, 41.9002044, 41.9073912]

    for i=1:4
        diff = abs(bounds_arr[i] - bounds_actual[i])
        @test diff < 0.01
    end
end
