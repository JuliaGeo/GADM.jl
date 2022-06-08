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
    GADM.download("VAT")
    @test_nowarn @datadep_str "GADM_VAT"
end

@testset "dataread" begin
    path = GADM.download("VAT")
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
    # valid country code
    country = GADM.get("IND")
    @test country isa NamedTuple
    @test GeoInterface.geomtrait(country.geom[1]) isa MultiPolygonTrait
    # get country and states
    country, states = GADM.get("IND";depth=0), GADM.get("IND", depth=1)
    @test country isa NamedTuple
    @test states isa NamedTuple
    @test GeoInterface.geomtrait(country.geom[1]) isa MultiPolygonTrait
    @test length(states) == 11 #number of fields in named tuple
    geometries = Tables.getcolumn(states, Symbol("geom"))
    @test length(geometries) == 36 # number of rows
    # throws error when query is invalid
    @test_throws ArgumentError GADM.get("IND", "Rio De Janerio")
    # throws argument error for supplying deeper region than available in dataset
    @test_throws ArgumentError GADM.get("VAT", "Pope")

    # depth tests
    level0 = GADM.get("IND", depth=0)
    level1 = GADM.get("IND", depth=1)
    level2 = GADM.get("IND", depth=2)
    level3 = GADM.get("IND", depth=3)
    @test length(Tables.getcolumn(level0, :geom)) == 1
    @test length(Tables.getcolumn(level1, :geom)) == 36
    @test length(Tables.getcolumn(level2, :geom)) == 666
    @test length(Tables.getcolumn(level3, :geom)) == 2340
    
    somecities = ["Mumbai City", "Bangalore", "Chennai"]
    @test issubset(somecities, level2.NAME_2)

    # throws argument error when the level is deeper than available in dataset
    @test_throws ArgumentError GADM.get("IND", depth=4)
end

@testset "basic" begin
    polygon = GADM.get("VAT")
    bounds = ArchGDAL.envelope(polygon.geom[1])
    bounds_arr = [bounds.MinX, bounds.MaxX, bounds.MinY, bounds.MaxY]

    # Vatican City bounding boxes lat min 41.9002044 lat max 41.9073912 lon min 12.4457442 lon max 12.4583653
    bounds_actual = [12.4457442, 12.4583653, 41.9002044, 41.9073912]

    for i=1:4
        diff = abs(bounds_arr[i] - bounds_actual[i])
        @test diff < 0.01
    end
end