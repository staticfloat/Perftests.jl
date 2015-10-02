module Perftests

export get_perf_groups, run_perf_groups, @perf, meta

using Benchmarks
using Compat

# This is where we expect to get our performance regression code
const perfdir = abspath(joinpath(dirname(@__FILE__),"../benchmarks/"))

# This is the default group, set by run_perf_groups() below
default_group = ""

# This is the directory where we'll plop out our .csv files
const resultsdir = joinpath(perfdir, "../test/results-$(Base.GIT_VERSION_INFO.commit)")


# This object represents metadata about a perf test; group/name/variant is a hierarchical
# organization of the perf tests where name is the only required member of the triplet; group
# defaults to the name of the directory holding the test, variant defaults to the empty string.
# Description is a human-readable description of the test, and issue is the JuliaLang github repo
# issue (if any) related to this test.
immutable meta
    group::AbstractString
    name::AbstractString
    variant::AbstractString

    description::AbstractString
    issue::UInt32

    meta(name; issue=0) = new(default_group, name, "", "", issue)
    meta(name, desc; issue=0) = new(default_group, name, "", desc, issue)
    meta(name, variant, desc; issue=0) = new(default_group, name, variant, desc, issue)
    meta(group, name, variant, desc; issue=0) = new(group, name, variant, desc, issue)
end

# This macro takes in a test expression and a PerfMetadata object
macro perf(ex, outer_meta)
    quote
        meta = $(esc(outer_meta))
        if contains(meta.group, "-") || contains(meta.name, "-") || contains(meta.variant, "-")
            throw(ArgumentError("Benchmark group/name/variant cannot contain '-'!"))
        end
        result = @benchmark $(esc(ex))
        stats = Benchmarks.SummaryStatistics(result)
        pts = Benchmarks.pretty_time_string
        time_str = "$(pts(stats.elapsed_time_center))"
        if !isnull(stats.elapsed_time_lower) && !isnull(stats.elapsed_time_upper)
            lower = stats.elapsed_time_lower.value
            upper = stats.elapsed_time_upper.value
            time_str *= " [$(pts(lower)), $(pts(upper))]"
        end
        if length(meta.variant) > 0
            csvpath = "$resultsdir/$(meta.group)-$(meta.name)-$(meta.variant).csv"
            println("$(meta.group)/$(meta.name)/$(meta.variant) done in $time_str")
        else
            csvpath = "$resultsdir/$(meta.group)-$(meta.name).csv"
            println("$(meta.group)/$(meta.name) done in $time_str")
        end
        writecsv(joinpath(perfdir, csvpath), result.samples)
    end
end

# Let's find all of our test groups; that's any directory inside benchmarks/
# us that has a perf.jl in it that we can call:
function get_perf_groups()
    return filter(x -> isfile(joinpath(perfdir,x,"perf.jl")), readdir(perfdir))
end

function run_perf_groups()
    return run_perf_groups(get_perf_groups())
end

function run_perf_groups(perf_groups)
    global default_group
    # Write out environment to $resultsdir/env.csv
    cd(perfdir)
    try mkdir(resultsdir) end
    writecsv(joinpath(perfdir, resultsdir, "env.csv"), Benchmarks.Environment())

    # Iterate, my friend.  Iterate.
    for dir in perf_groups
        # Set the default group first
        default_group = dir
        println("Running $dir/perf.jl...")
        include(joinpath(perfdir,dir,"perf.jl"))
    end
end

end # module
