using Geography
using Test

testfiles = [
    "download.jl"
]

@testset "Geography.jl" begin
for testfile in testfiles
    include(testfile)
  end
end
