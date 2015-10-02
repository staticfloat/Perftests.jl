abstract List{T}

type Nil{T} <: List{T}
end

type Cons{T} <: List{T}
    head::T
    tail::List{T}
end

function listn1n2(n1::Int,n2::Int)
    l1 = Nil{Int}()
    for i=n2:-1:n1
        l1 = Cons{Int}(i,l1)
    end
    l1
end

@perf listn1n2(1,10^6) meta("cons", "List concatenation")

# issue #1211
include("ziggurat.jl")
a = Array(Float64, 1000000)
@perf randn_zig!(a) meta("randn_zig", "Ziggurat gaussian number generator", issue=1211)

# issue #950
include("gk.jl")
@perf gk(350,[0.1]) meta("gk", "Grigoriadis Khachiyan matrix games", issue=950)


# issue #942
x = sparse(ones(280,280));
@perf (x*x) meta("sparsematmul", "normal", "Sparse matrix multiplication", issue=942)
s2 = sparse(rand(1:2000,10^5), kron([1:10^4;],ones(Int,10)), ones(Int,10^5), 2000, 10^4);
@perf s2*s2' meta("sparsematmul", "fillin", "Sparse matrix multiplication with fill-in", issue=942)

# issue #938
x = 1:600000;
@perf sparse(x,x,x) meta("sparserange", "Construction of a sparse matrix from ranges", issue=938)

# issue 4707
include("getdivgrad.jl")
A = getDivGrad(64,64,64)
v = rand(64^3)
@perf A*v meta("sparsemat_densevec", "Sparse matrix - dense vector multiplication", issue=4707)

# issue #939
y = [500000:-1:1;]
@perf sortperm(y) meta("sortperm", "Sorting of a worst-case vector", issue=939)

# issue #445
include("stockcorr.jl")
@perf stockcorr() meta("stockcorr", "Correlation analysis of random matrices", issue=445)



include("bench_eu.jl")
@perf bench_eu_vec(10000) meta("finance", "vectorized", "Vectorized Monte Carlo financial simulation")
@perf bench_eu_devec(10000) meta("finance", "devectorized", "Devectorized Monte Carlo financial simulation")

# issue #1163
include("actor_centrality.jl")
@perf actor_centrality() meta("actorgraph", "Centrality of actors in IMDB database", issue=1163)

# issue #1168
include("laplace.jl")
@perf laplace_vec() meta("laplace", "vectorized", "Vectorized Laplacian", issue=1168)
@perf laplace_devec() meta("laplace", "devectorized", "Devectorized Laplacian", issue=1168)

# issue #1169
include("go_benchmark.jl")
@perf benchmark(10) meta("go","Simulation of random games of Go", issue=1169)

# issue #3142
include("simplex.jl")
@perf doTwoPassRatioTest() meta("simplex", "Dual simplex algorithm for Linear Programming", issue=3142)

# issue #3811
include("raytracer.jl")
@perf Raytracer(5, 256, 4) meta("raytracer", "Simple native Julia raytracer", issue=3811)

function cmp_with_func(x::Vector, f::Function)
    count::Int = 0
    for i = 1:length(x)-1
      if f(x[i], x[i+1]) count += 1 end
    end
    count
end
x = randn(200_000)
@perf cmp_with_func(x, isless) meta("funarg", "Function argument benchmark")


arith_vectorized(b,c,d) = b.*c + d .+ 1.0
len = 1_000_000
b = randn(len)
c = randn(len)
d = randn(len)
@perf arith_vectorized(b,c,d) meta("vectorize", "Vectorized arithmetic")


open("random.csv","w") do io
    writecsv(io, rand(100000,4))
end
function parsecsv()
    for line in EachLine(open("random.csv"))
        split(line, ',')
    end
end
@perf parsecsv() meta("splitline", "CSV parsing")
rm("random.csv")


include("json.jl")
@perf parse_json(_json_data) meta("json", "JSON parsing")

include("indexing.jl")
x = [1:100_000;]
y = filter(iseven, 1:length(x))
logical_y = map(iseven, 1:length(x))
@perf add1!(x,y) meta("indexing", "add1", "Increment vector x at locations y")
@perf devec_add1!(x,y) meta("indexing", "devectorized_add1", "Devectorized increment vector x at locations y")
@perf add1!(x,logical_y) meta("indexing", "add1_logical", "Increment x_i if y_i is true")
@perf devec_add1_logical!(x,logical_y) meta("indexing", "devectorized_add1_logical", "Devectorized increment x_i if y_i is true")
