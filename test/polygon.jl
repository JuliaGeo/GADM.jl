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