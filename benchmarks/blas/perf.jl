# This file is a part of Julia. License is MIT: http://julialang.org/license

include("level2.jl")
include("level3.jl")

sizes = [("tiny", 1), ("small", 4), ("medium", 6), ("large", 8), ("huge", 10)]
for (size_str, exp) in sizes
    # The length of vectors, size of matrices, etc...
    n = 2^exp

    # BLAS level 1 tests
    a = rand(n)
    b = rand(n)
    @perf Base.dot(a,b) @meta("dot", size_str, "Dot product with lengths 2^$exp")
    a = rand()
    x = rand(n)
    y = zeros(n)
    @perf Base.axpy!(a,x,y) @meta("axpy", size_str, "Vector add-multiply with lengths 2^$exp")

    # BLAS level 2 tests
    A = rand(n,n)
    x = rand(n)
    @perf A*x @meta("gemv", size_str, "Matrix-vector multiply with lengths 2^$exp")

    # BLAS level 3 tests
    a = rand(n,n)
    b = similar(a)
    @perf A_mul_B!(b, a, a) @meta("gemm", size_str, "Matrix-matrix multiply with lengths 2^$exp")
end
