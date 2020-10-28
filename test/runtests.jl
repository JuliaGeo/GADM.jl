using Geography
using Test
using DataDeps
using ArchGDAL

testfiles = [
    "download.jl",
    "polygon.jl"
]

@testset "Geography.jl" begin
  for testfile in testfiles
    include(testfile)
  end
end
