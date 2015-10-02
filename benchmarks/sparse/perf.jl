# This file is a part of Julia. License is MIT: http://julialang.org/license

## Sparse matrix performance
include("fem.jl")
@perf run_fem(256) meta("fem", "Finite Elements modeling")
