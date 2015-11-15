# This file is a part of Julia. License is MIT: http://julialang.org/license

module BlapackPerf

import BenchmarkTrackers
const BT = BenchmarkTrackers

mytracker = BT.BenchmarkTracker()

sizes = [("tiny", 1), ("small", 4), ("medium", 6), ("large", 8), ("huge", 10)]
for (size_str, exp) in sizes
    # The length of vectors, size of matrices, etc...
    n = 2^exp


    # BLAS level 1 tests
    a = rand(n)
    b = rand(n)
    @perf Base.dot(a,b) meta("dot", size_str, "Dot product with lengths 2^$exp")
    a = rand()
    x = rand(n)
    y = zeros(n)
    @perf Base.axpy!(a,x,y) meta("axpy", size_str, "Vector add-multiply with lengths 2^$exp")

    # BLAS level 2 tests
    A = rand(n,n)
    x = rand(n)
    @perf A*x meta("gemv", size_str, "Matrix-vector multiply with lengths 2^$exp")

    # BLAS level 3 tests
    B = similar(A)
    @perf A_mul_B!(B, A, A) meta("gemm", size_str, "Matrix-matrix multiply with lengths 2^$exp")

    # LAPACK eig tests
    AA = A + A'
    C = rand(n,n) + im*rand(n,n)
    @perf eig(A) meta("realeig", size_str, "Real matrix eigenfactorization with lengths 2^$exp")
    @perf eig(A + A') meta("symeig", size_str, "Symmetric matrix eigenfactorization with lengths 2^$exp")
    @perf eig(C + C') meta("hermeig", size_str, "Hermitian matrix eigenfactorization with lengths 2^$exp")

    # LAPACK factorization tests
    @perf svdfact(A) meta("svdfact", size_str, "Singular Value Decomposition with lengths 2^$exp")
    @perf schurfact(A) meta("schurfact", size_str, "Schur factorization with lengths 2^$exp")
    @perf cholfact(A'*A) meta("cholfact", size_str, "Cholesky factorization with lengths 2^$exp")
    @perf qrfact(A) meta("qrfact", size_str, "QR factorizaiton with lengths 2^$exp")
    @perf lufact(A) meta("lufact", size_str, "LU factorizaiton with lengths 2^$exp")
end

end # module
