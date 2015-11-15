# This file is a part of Julia. License is MIT: http://julialang.org/license

module SortPerf
import Perftests: @perf, meta

using Base.Sort
import Base.Sort: QuickSort, MergeSort, InsertionSort

Pkg.add("SortingAlgorithms")
using SortingAlgorithms #Provides the other sorting algorithms

sorts = [InsertionSort, QuickSort, MergeSort, HeapSort, RadixSort, TimSort]

randstr_fn!(str_len::Int) = d -> (for i = 1:length(d); d[i] = randstring(str_len); end; d)
randint_fn!(m::Int) = d -> rand!(d, 1:m)

# Run the full gamut of tests
for (T, typename, randfn!) in [(Int, string(Int), randint_fn!(10)),
                                (Float64, string(Float64), rand!),
                                (AbstractString, "String_05", randstr_fn!(5)),
                                (AbstractString, "String_10", randstr_fn!(10))]
    for logsize = 6:2:18
        size = 2^logsize
        for s in sorts
            if s == RadixSort && T == AbstractString continue end      #Radix sort not implemented
            if s == InsertionSort && logsize >=14 continue end #Too slow

            data = Array(T, size)
            gc()

            # Note; we're using an anonymous function here so that
            perfsort = (data) -> sort(data, alg=s)

            # Randomize the data, measure the sorting, then measure the sorting again
            typesize = "$(typename)_$(logsize)"
            sname = string(s)[1:end-5]
            sname = sname[rsearch(sname,'.')+1:end]

            randfn!(data)
            @perf perfsort(data) meta(sname, "$(typesize)_random", "Sorting of randomized data")
            sort!(data)
            @perf perfsort(data) meta(sname, "$(typesize)_sorted", "Sorting of sorted data")

            # Measure it after reversing the data
            rdata = reverse(data)
            @perf perfsort(rdata) meta(sname, "$(typesize)_reverse", "Sorting of reverse-sorted data")

            ## Sorted with 3 exchanges
            for i = 1:3
                n1 = rand(1:size)
                n2 = rand(1:size)
                data[n1], data[n2] = data[n2], data[n1]
            end
            @perf perfsort(data) meta(sname, "$(typesize)_3exchanges", "Sorting of sorted data with three exchanges")

            ## Sorted with 10 unsorted values appended
            sort!(data)
            data[end-9:end] = randfn!(Array(T,10))
            @perf perfsort(data) meta(sname, "$(typesize)_appended", "Sorting of data with 10 appended unsorted values")

            ## Random data with 4 unique values
            data4 = data[rand(1:4,size)]
            @perf perfsort(data4) meta(sname, "$(typesize)_4unique", "Sorting of data with only 4 unique values")

            ## All values equal
            data1 = data[ones(Int, size)]
            @perf perfsort(data1) meta(sname, "$(typesize)_allequal", "Sorting of completely homogenous data")

            ## QuickSort median killer
            if s == QuickSort && logsize > 16; continue; end  # too slow!

            data = data[1:size>>1]
            data = sort!(data)
            data = vcat(reverse(data), data)
            @perf perfsort(data) meta(sname, "$(typesize)_qsortkiller", "Sorting of qsort worst case")
        end
    end
end

end # module
