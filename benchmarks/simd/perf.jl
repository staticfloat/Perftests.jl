# This file is a part of Julia. License is MIT: http://julialang.org/license

module SimdPerf
import Perftests: @perf, meta

# Compute y += a*x using @simd for vectors x and y
function simd_axpy( a, x, y )
    # LLVM's auto-vectorizer typically vectorizes this loop even without @simd
    @simd for i=1:length(x)
        @inbounds y[i] += a*x[i]
    end
end

# Compute a sum reduction using @simd for vector x, with certain starting and ending indices
function sum_reduce(x, istart, iend)
    s = zero(eltype(x))
    @simd for i = istart:iend
        @inbounds s += x[i]
    end
    s
end
function flog_sum_reduce( m, x )
    s = zero(eltype(x))
    for j=1:m
        # Try different starting and ending indices.
        s += sum_reduce(x,j,length(x)-(j-1))
    end
    return s
end

# Inner product of x and y
function simd_dot( x, y )
    s = zero(eltype(x))
    @simd for i=1:length(x)
        @inbounds s += x[i]*y[i]
    end
    s
end

# This guy, we will keep in his own file since he's nontrivial
include("seismic_fdtd.jl")

for t in [Float32,Float64]
    n = 1000
    x = rand(t,n)
    y = rand(t,n)
    a = convert(t,0.5)

    # Test axpy performance
    @perf simd_axpy(a,x,y) meta("axpy", string(t), "SIMD BLAS axpy for type $t")

    # Test sum reduction performance
    @perf flog_sum_reduce(1000,x) meta("sum", string(t), "SIMD sum reduction over array of type $t")

    # Test dot performance
    @perf simd_dot(x, y) meta("dot", string(t), "SIMD inner product for type $t")

    # Test 2D seismic simulation
    m = 200
    n = 200
    A = fill(convert(t,0.2),m,n)
    B = fill(convert(t,0.25),m,n)
    U = rand(t,m,n) .- convert(t,.5)
    Vx = zeros(t,m,n)
    Vy = zeros(t,m,n)
    @perf flog_fdtd(10,U,Vx,Vy,A,B) meta("seismic_fdtd", string(t), "2D finite-difference seismic simulation for $t")
end

end # module
