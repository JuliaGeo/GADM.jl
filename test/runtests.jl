using Geography
using Test
using DataDeps
using ArchGDAL

# DataDeps always downloads the data if it doesn't exist
ENV["DATADEPS_ALWAYS_ACCEPT"] = true

testfiles = [
    "download.jl",
    "polygon.jl"
]

@testset "Geography.jl" begin
  for testfile in testfiles
    include(testfile)
  end
end
