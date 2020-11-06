@testset "isvalidcode" begin
    @test GADM.isvalidcode("IND")
    @test GADM.isvalidcode("BRA")
    @test GADM.isvalidcode("USA")
    @test !GADM.isvalidcode("ind")
    @test !GADM.isvalidcode("")
    @test !GADM.isvalidcode("iNd4")
end

function getmeshespolygon(polygon)
    #converts [Float, Float] to Meshes Point object
    topoint2f = x -> Meshes.Point2f(x)
    coordinates = GeoInterface.coordinates(geometry)

    if string(ArchGDAL.getgeomtype(geometry)) === "wkbMultiPolygon"
        outer = map(topoint2f, first(coordinates[1]))
        inner = []
        if length(coordinates) > 1
            for ring in coordinates[2:end]
                push!(inner, map(topoint2f, first(ring)))
            end
        end
        return Meshes.Polygon(outer, inner)
    else
        outer = map(topoint2f, first(coordinates))
        return Meshes.Polygon(outer)
    end
end

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
    @test_throws ArgumentError GADM.polygon("IND", "Rio De Janerio")
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
    resource_data_path = GADM.download("GADM_IND")

    dataset = GADM.extractdataset(resource_data_path)
    @test typeof(dataset) === ArchGDAL.IDataset

    @test_throws SystemError GADM.extractdataset("")
end

@testset "extractgeometry" begin
    resource_data_path = GADM.download("GADM_IND")
    
    dataset = GADM.extractdataset(resource_data_path)

    geometry = GADM.extractgeometry(dataset)
    @test typeof(geometry) === ArchGDAL.IGeometry
end

@testset "getlevel" begin
    resource_data_path = GADM.download("GADM_IND")
    dataset = GADM.extractdataset(resource_data_path)

    # incorrect level
    @test_throws ArgumentError GADM.getlevel(dataset, 10)

    # correct level
    feature_layer = GADM.getlevel(dataset, 0)
    @test typeof(feature_layer) === ArchGDAL.IFeatureLayer
end

@testset "basic" begin
    geom = GADM.polygon("VAT")

    bounds = ArchGDAL.envelope(geom)

    bounds_arr = [bounds.MinX, bounds.MaxX, bounds.MinY, bounds.MaxY]

    # Vatican City bounding boxes lat min 41.9002044 lat max 41.9073912 lon min 12.4457442 lon max 12.4583653
    bounds_actual = [12.4457442, 12.4583653, 41.9002044, 41.9073912]

    for i=1:4
        diff = abs(bounds_arr[i] - bounds_actual[i])
        @test diff < 0.01
    end
end
