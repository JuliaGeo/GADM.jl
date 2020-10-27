@testset "Download" begin
    # dataurl returns a string on proper formatted code GADM_<Code>
    url = Geography.dataurl("GADM_IND")
    @test isequal(url, "https://biogeo.ucdavis.edu/data/gadm3.6/gpkg/gadm36_IND_gpkg.zip")

    # dataurl returns nothing on improper formatted code GADM<Code>
    url = Geography.dataurl("GADMIND")
    @test isnothing(url)

    # dataurl returns nothing when code doesn't contain GADM
    url = Geography.dataurl("IND")
    @test isnothing(url)

    # dataurl returns nothing on empty string
    url = Geography.dataurl("")
    @test isnothing(url)
end