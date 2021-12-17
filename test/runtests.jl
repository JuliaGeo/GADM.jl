using GADM
using Test
using DataDeps
using ArchGDAL
using GeoInterface
using Tables

testfiles = [
    "GADM.jl",
]

@testset "GADM.jl" begin
  for testfile in testfiles
    include(testfile)
  end
end
