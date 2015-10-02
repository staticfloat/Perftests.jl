# Perftests

A redo of the main Julia `test/perf` directory.  Retooled to use [`Benchmarks.jl`](https://github.com/johnmyleswhite/Benchmarks.jl), this repository will spit out a bunch of .csv files into the `test/results-$COMMIT` directory (Where `$COMMIT` is the commit value of the version of Julia you are running) and display small summary statistics as it does so.

To run a specific group of tests, use `run_perf_groups()`.  For example, to run and output the `.csv` files for the `kernel` and `simd` performance tests, one would write:

```julia
using Perftests
run_perf_groups(["kernel", "simd"])
```

# Test organization
Tests are organized foremost by group, then name, then variant.  Not all tests are required to have variants, but they fit into a natural hierarchy when running the same test across multiple element types, for example.  The resultant `.csv` files are named `$group-$name-$variant.csv`, for ease of access.
