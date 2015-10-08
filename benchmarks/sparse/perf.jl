# This file is a part of Julia. License is MIT: http://julialang.org/license

module SparsePerf
import Perftests: @perf, meta

## Sparse matrix performance
include("fem.jl")
@perf run_fem(256) meta("fem", "Finite Elements modeling")

# matsize = [log2(size(A,1)), log2(nnz(A))]
matsize = ([12,0], [12,6], [18,0], [18,9])

# indsize = log2(length(I))
indsize = [0, 8, 4]

function skinny_index(A,I)
    A[I,1]
end

for (m_log2,nz_log2) in matsize
    m = 2.^m_log2
    nz = 2.^nz_log2
    A = sprand(m,1,nz/m)
    for n_log2 in indsize
        n = 2.^n_log2
        I = rand(1:m,n)
        @perf A[I,1] meta("getindex_skinny", "m$(m)_nz$(nz)_n$(n)", "Sparse 2^$(m_log2)x1 matrix with 2^$(nz_log2) nonzero elements, indexed by 2^$(n_log2) elements")
    end
end

end # module
