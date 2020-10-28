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