# This file is a part of Julia. License is MIT: http://julialang.org/license

function hvcat_perf(a,b)
    return [a b; b a]
end

function hvcat_setind_perf(a, b)
    n = size(a,1)
    c = Array(Float64,2n,2n)
    c[  1:n,    1:n  ] = a
    c[  1:n,  n+1:end] = b
    c[n+1:end,  1:n  ] = b
    c[n+1:end,n+1:end] = a
    return c
end


function hcat_perf(a,b)
    return [a b b a]
end

function hcat_setind_perf(a,b)
    n = size(a,1)
    c = Array(Float64, n, 4n)
    c[:,    1:  n] = a
    c[:,  n+1: 2n] = b
    c[:, 2n+1: 3n] = b
    c[:, 3n+1:end] = a
    return c
end

function vcat_perf(a,b)
    return [a; b; b; a]
end

function vcat_setind_perf(a,b)
    n = size(a,1)
    c = Array(Float64, 4n, n)
    c[   1: n, :] = a
    c[ n+1:2n, :] = b
    c[2n+1:3n, :] = b
    c[3n+1:4n, :] = a
    return c
end

function catnd_perf(a,b)
    return cat(3, a, b, b, a)
end

function catnd_setind_perf(a, b)
    n = size(a,2)
    c = Array(Float64, 1, n, 4n, 1)
    c[1,:,   1: n,1] = a
    c[1,:, n+1:2n,1] = b
    c[1,:,2n+1:3n,1] = b
    c[1,:,3n+1:4n,1] = a
    return c
end

sizes = [("small", 5), ("large", 500)]
for (size_str, n) in sizes
    a = rand(n,n)
    b = rand(n,n)
    @perf hvcat_perf(a,b) meta("hvcat", size_str, "Horizontal/vertical matrix concatenation")
    @perf hvcat_setind_perf(a,b) meta("hvcat_setind", size_str, "Horizontal/vertical matrix concatenation using setindex")
    @perf hcat_perf(a,b) meta("hcat", size_str, "Horizontal matrix concatenation")
    @perf hcat_setind_perf(a,b) meta("hcat_setind", size_str, "Horizontal matrix concatenation using setindex")
    @perf vcat_perf(a,b) meta("vcat", size_str, "Vertical matrix concatenation")
    @perf vcat_setind_perf(a,b) meta("vcat_setind", size_str, "Vertical matrix concatenation using setindex")

    a = rand(1,n,n,1)
    b = rand(1,n,n)
    @perf catnd_perf(a,b) meta("catnd", size_str, "N-dimensional matrix concatenation")
    @perf catnd_setind_perf(a,b) meta("catnd_setind", size_str, "N-dimensional matrix concatenation using setindex")
end
