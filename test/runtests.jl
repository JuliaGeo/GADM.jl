using GADM
using DataDeps
using ArchGDAL
using GeoInterface
using Tables
using Test

testfiles = [
    "GADM.jl",
]

@testset "GADM.jl" begin
  for testfile in testfiles
    include(testfile)
  end
end
