# This file is a part of Julia. License is MIT: http://julialang.org/license

module ArrayPerf

import BenchmarkTrackers
const BT = BenchmarkTrackers

mytracker = BT.BenchmarkTracker()

# Perform indexing benchmarks to look at array indexing performance across a variety of factors such
# as element type, array size, array layout and access pattern.
include("indexing.jl")
briefname(A) = typeof(A).name.name

for (size_str, sz) in [("Small", (3,5)), ("Large", (300,500))]
    for elem_type in [Int, Float32]
        arrays = makearrays(elem_type, sz)
        for A in arrays
            # Bake a string containing the element type, size string and layout of the array
            elsizelay = "$(elem_type)/$(size_str)/$(briefname(A))"

            # Start a BenchmarkTracker @track block
            BT.@track mytracker begin
                BT.@benchmarks begin
                    "array/sum/iteration/$elsizelay" => sum_iteration(A, 10^5)  # for i in A
                    "array/sum/eachindex/$elsizelay" => sum_eachindex(A, 10^5)  # for i in eachindex(a)
                    "array/sum/linear/$elsizelay" => sum_linear(A, 10^5)        # for I in 1:length(A)
                    "array/sum/cartesian/$elsizelay" => sum_cartesian(A, 10^5)  # for I in CartesianRange(size(A))
                    "array/sum/colon/$elsizelay" => sum_colon(A, 10^5)          # colon indexing
                    "array/sum/range/$elsizelay" => sum_range(A, 10^5)          # range indexing
                    "array/sum/logical/$elsizelay" => sum_logical(A, 10^5)      # logical indexing
                    "array/sum/vector/$elsizelay" => sum_vector(A, 10^5)        # vector indexing
                end

                # Tags can be used to filter benchmarks for execution and comparison.
                BT.@tags "array" "summation"
            end
        end # array layout loop
    end # element type for loop
end # size for loop


include("lucompletepiv.jl")
for n = [100, 250, 500, 1000]
    BT.@track mytracker begin
        BT.@setup begin
            A = randn(n,n)
        end

        BT.@benchmarks begin
            "array/lupiv_copy/$(n)x$(n)" => lucompletepivCopy!(A) # LU facorization with copy slices
            "array/lupiv_view/$(n)x$(n)" => lucompletepivCopy!(A) # LU facorization with view slices
        end

        BT.@tags "array" "lupiv"
    end
end

BT.run(mytracker)
end # module
