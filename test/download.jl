@testset "dataurl" begin
    # dataurl returns a string on proper formatted code GADM_<Code>
    url = Geography.dataurl("GADM_IND")
    @test isequal(url, "https://biogeo.ucdavis.edu/data/gadm3.6/gpkg/gadm36_IND_gpkg.zip")

    # dataurl returns nothing on improper formatted code GADM<Code>    
    @test_throws ArgumentError Geography.dataurl("GADMIND")

    # dataurl returns nothing when code doesn't contain GADM
    @test_throws ArgumentError Geography.dataurl("IND")

    # dataurl returns nothing on empty string
    @test_throws ArgumentError Geography.dataurl("")
end