using GADM
using Test
using DataDeps
using ArchGDAL
import GeoInterface

# DataDeps always downloads the data if it doesn't exist
ENV["DATADEPS_ALWAYS_ACCEPT"] = true

testfiles = [
    "GADM.jl",
]

@testset "GADM.jl" begin
  for testfile in testfiles
    include(testfile)
  end
end
