# This file is a part of Julia. License is MIT: http://julialang.org/license

include("indexing.jl")
briefname(A) = typeof(A).name.name
# Run through small array tests, large array tests, Integer array tests, Float array tests, etc...
for (size_str, sz) in [("Small", (3,5)), ("Large", (300,500))]
    for elem_type in [Int, Float32]
        Alist = makearrays(elem_type, sz)
        for Ar in Alist
            bAr = briefname(Ar)
            @perf sum_iteration(Ar, 10^5) @meta("sum_iteration", "$(elem_type)$(size_str)$bAr", "for a in A indexing")
            @perf sum_eachindex(Ar, 10^5) @meta("sum_eachindex", "$(elem_type)$(size_str)$bAr", "for I in eachindex(A)")
            @perf sum_linear(Ar, 10^5) @meta("sum_linear", "$(elem_type)$(size_str)$bAr", "for I in 1:length(A)")
            @perf sum_cartesian(Ar, 10^5) @meta("sum_cartesian ", "$(elem_type)$(size_str)$bAr", "for I in CartesianRange(size(A))")
            @perf sum_colon(Ar, 10^5) @meta("sum_colon ", "$(elem_type)$(size_str)$bAr", "colon indexing")
            @perf sum_range(Ar, 10^5) @meta("sum_range ", "$(elem_type)$(size_str)$bAr", "range indexing")
            @perf sum_logical(Ar, 10^5) @meta("sum_logical ", "$(elem_type)$(size_str)$bAr", "logical indexing")
            @perf sum_vector(Ar, 10^5) @meta("sum_vector ", "$(elem_type)$(size_str)$bAr", "vector indexing")
        end
    end
end

include("lucompletepiv.jl")
for n = [100, 250, 500, 1000]
    A = randn(n,n)
    @perf lucompletepivCopy!(A) @meta("lupiv_copy", "$(n)x$(n)", "LU facorization with copy slices")
end

for n = [100, 250, 500, 1000]
    A = randn(n,n)
    @perf lucompletepivCopy!(A) @meta("lupiv_view", "$(n)x$(n)", "LU facorization with view slices")
end
