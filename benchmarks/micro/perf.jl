# This file is a part of Julia. License is MIT: http://julialang.org/license

## recursive fib ##
fib(n) = n < 2 ? n : fib(n-1) + fib(n-2)
@perf fib(20) meta("fib", "Recursive fibonacci")

## parse integer ##
function parseintperf(t)
    local n, m
    for i=1:t
        n = rand(UInt32)
        s = hex(n)
        m = UInt32(parse(Int64,s,16))
    end
    return n
end

@perf parseintperf(1000) meta("parse_int", "Integer parsing")

## mandelbrot set: complex arithmetic and comprehensions ##

function mandel(z)
    c = z
    maxiter = 80
    for n = 1:maxiter
        if abs(z) > 2
            return n-1
        end
        z = z^2 + c
    end
    return maxiter
end

mandelperf() = [mandel(complex(r,i)) for i=-1.:.1:1., r=-2.0:.1:0.5]
@perf mandelperf() meta("mandel", "Calculation of mandelbrot set")

## numeric vector sort ##
function qsort!(a,lo,hi)
    i, j = lo, hi
    while i < hi
        pivot = a[(lo+hi)>>>1]
        while i <= j
            while a[i] < pivot; i += 1; end
            while a[j] > pivot; j -= 1; end
            if i <= j
                a[i], a[j] = a[j], a[i]
                i, j = i+1, j-1
            end
        end
        if lo < j; qsort!(a,lo,j); end
        lo, j = i, hi
    end
    return a
end

sortperf(n) = qsort!(rand(n), 1, n)
@perf sortperf(5000) meta("quicksort", "Sorting of random numbers using quicksort")

## slow pi series ##
function pisum()
    sum = 0.0
    for j = 1:500
        sum = 0.0
        for k = 1:10000
            sum += 1.0/(k*k)
        end
    end
    sum
end
@perf pisum() meta("pi_sum", "devectorized", "Devectorized summation of a power series")

## slow pi series, vectorized ##
function pisumvec()
    s = 0.0
    a = [1:10000]
    for j = 1:500
        s = sum(1./(a.^2))
    end
    s
end

@perf pisumvec() meta("pi_sum", "vectorized", "Vectorized summation of a power series")

## random matrix statistics ##
function randmatstat(t)
    n = 5
    v = zeros(t)
    w = zeros(t)
    for i=1:t
        a = randn(n,n)
        b = randn(n,n)
        c = randn(n,n)
        d = randn(n,n)
        P = [a b c d]
        Q = [a b; c d]
        v[i] = trace((P.'*P)^4)
        w[i] = trace((Q.'*Q)^4)
    end
    return (std(v)/mean(v), std(w)/mean(w))
end

@perf randmatstat(1000) meta("rand_mat_stat", "Statistics on a random matrix")

## largish random number gen & matmul ##

@perf rand(1000,1000)*rand(1000,1000) meta("rand_mat_mul", "Multiplication of random matrices")

## printfd ##
@unix_only begin
    function printfd(n)
        open("/dev/null","w") do io
            for i = 1:n
                @printf(io,"%d %d\n",i,i+1)
            end
        end
    end

    printfd(1)
    @perf printfd(100000) meta("printfd", "Printing to a file descriptor")
end
