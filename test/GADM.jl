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
    GADM.download("SUR")
    GADM.download("IND")
    @test_nowarn @datadep_str "GADM_VAT"
    @test_nowarn @datadep_str "GADM_SUR"
    @test_nowarn @datadep_str "GADM_IND"

    # error: invalid API version
    @test_throws ArgumentError GADM.download("VAT", version="4.2")
    # error: country code "GER" not found
    @test_throws ArgumentError GADM.download("GER")
end

@testset "dataread" begin
    path = GADM.download("VAT")
    data = GADM.dataread(path)
    @test data isa ArchGDAL.IDataset
end

@testset "other API versions" begin
    path28 = GADM.download("FRA", version="2.8")
    path36 = GADM.download("GRC", version="3.6")
    path40 = GADM.download("ITA", version="4.0")
    @test_nowarn @datadep_str "GADM_FRA"
    @test_nowarn @datadep_str "GADM_GRC"
    @test_nowarn @datadep_str "GADM_ITA"

    data28 = GADM.dataread(path28)
    data36 = GADM.dataread(path36)
    data40 = GADM.dataread(path40)
    @test data28 isa ArchGDAL.IDataset
    @test data36 isa ArchGDAL.IDataset
    @test data40 isa ArchGDAL.IDataset
end

@testset "getlayer" begin
    path = GADM.download("IND")
    data = GADM.dataread(path)

    # incorrect level
    @test_throws ArgumentError GADM.getlayer(data, 10)

    # correct level
    layer = GADM.getlayer(data, 0)
    @test layer isa ArchGDAL.IFeatureLayer
end

@testset "get" begin
    # invalid country codes
    @test_throws ArgumentError GADM.get("ind")    
    @test_throws ArgumentError GADM.get("")   
    @test_throws ArgumentError GADM.get("IND4")   

    # valid country code
    country = GADM.get("IND")
    @test Tables.istable(country)
    @test Tables.rowaccess(country)
    row = Tables.rows(country) |> first
    @test GeoInterface.geomtrait(Tables.getcolumn(row, :geom)) isa MultiPolygonTrait

    # get country and states
    country, states = GADM.get("IND", depth=0), GADM.get("IND", depth=1)
    @test Tables.istable(country)
    @test Tables.istable(states)
    row = Tables.rows(country) |> first
    @test GeoInterface.geomtrait(Tables.getcolumn(row, :geom)) isa MultiPolygonTrait
    rows = Tables.rows(states)
    row = rows |> first
    @test length(rows) == 41 # number of rows
    @test length(Tables.columnnames(row)) == 12 # number of fields in table

    # throws error when query is invalid
    @test_throws ArgumentError GADM.get("IND", "Rio de Janeiro")

    # throws argument error for supplying deeper region than available in dataset
    @test_throws ArgumentError GADM.get("VAT", "Pope")

    # depth tests
    level0 = GADM.get("IND", depth=0)
    level1 = GADM.get("IND", depth=1)
    level2 = GADM.get("IND", depth=2)
    level3 = GADM.get("IND", depth=3)
    @test length(Tables.rows(level0)) == 6
    @test length(Tables.rows(level1)) == 41
    @test length(Tables.rows(level2)) == 676
    @test length(Tables.rows(level3)) == 2347
    
    somecities = ["Mumbai City", "Bangalore", "Chennai"]
    level2cols = Tables.columns(level2)
    @test issubset(somecities, Tables.getcolumn(level2cols, :NAME_2))

    # throws argument error when the level is deeper than available in dataset
    @test_throws ArgumentError GADM.get("IND", depth=4)

    # subregions tests
    subregions = GADM.get("SUR", "Para", depth=1) |> Tables.columns
    expected = ["Bigi Poika", "Carolina", "Noord", "Oost", "Zuid"]
    @test issetequal(Tables.getcolumn(subregions, :NAME_2), expected)

    # subregions with same name
    suriname = GADM.get("SUR", depth=2) |> Tables.columns
    @test count(==("Welgelegen"), Tables.getcolumn(suriname, :NAME_2)) == 2

    coronie = GADM.get("SUR", "Coronie", "Welgelegen") |> Tables.columns
    paramaribo = GADM.get("SUR", "Paramaribo", "Welgelegen") |> Tables.columns
    @test length(Tables.getcolumn(coronie, :NAME_1)) == length(Tables.getcolumn(paramaribo, :NAME_1)) == 1
    @test Tables.getcolumn(coronie, :NAME_1) ≠ Tables.getcolumn(paramaribo, :NAME_1)

    # invalid subregion
    @test_throws ArgumentError GADM.get("SUR", "a", "Welgelegen")
end

@testset "basic" begin
    polygon = GADM.get("VAT")
    row = Tables.rows(polygon) |> first
    bounds = ArchGDAL.envelope(Tables.getcolumn(row, :geom))
    bounds_arr = [bounds.MinX, bounds.MaxX, bounds.MinY, bounds.MaxY]

    # Vatican City bounding boxes lat min 41.9002044 lat max 41.9073912 lon min 12.4457442 lon max 12.4583653
    bounds_actual = [12.4457442, 12.4583653, 41.9002044, 41.9073912]

    for i=1:4
        diff = abs(bounds_arr[i] - bounds_actual[i])
        @test diff < 0.01
    end
end