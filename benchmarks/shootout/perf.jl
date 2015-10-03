# This file is a part of Julia. License is MIT: http://julialang.org/license

module ShootoutPerf
import Perftests: @perf, meta

# Find relative paths easily
rpath(filename) = joinpath(dirname(@__FILE__), filename)
function download_if_needed(url)
    path = joinpath(dirname(@__FILE__),basename(url))
    if !isfile(path)
        println("Downloading $(basename(url))")
        download(url, path)
    end
end

# If we don't already have the input files we need, download them!
cache_url = "https://cache.e.ip.saba.us/http://benchmarksgame.alioth.debian.org/download"
in_and_outs = ["knucleotide", "regexdna", "revcomp"]
just_outs = ["spectralnorm",  "fasta", "mandelbrot", "nbody", "fannkuchredux", "pidigits", "meteor"]
for file in in_and_outs
    download_if_needed("$cache_url/$file-input.txt")
    download_if_needed("$cache_url/$file-output.txt")
end
for file in just_outs
    download_if_needed("$cache_url/$file-output.txt")
end

include("binary_trees.jl")
@perf binary_trees(10) meta("binary_trees", "Allocate and deallocate many many binary trees")

include("fannkuch.jl")
@perf fannkuch(7) meta("fannkuch", "Indexed-access to tiny integer-sequence")

include("fasta.jl")
@perf fasta(100) meta("fasta", "Generate and write random DNA sequences")

include("k_nucleotide.jl")
infile = rpath("knucleotide-input.txt")
@perf k_nucleotide(infile) meta("k_nucleotide", "Hashtable update and k-nucleotide strings")

include("mandelbrot.jl")
outfile = rpath("mandelbrot-output-julia.txt")
@perf mandelbrot(200, outfile) meta("mandelbrot", "Generate Mandelbrot set portable bitmap file")

include("meteor_contest.jl")
@perf meteor_contest() meta("meteor_contest", "Search for solutions to shape packing puzzle")

include("nbody.jl")
@perf NBody.nbody() meta("nbody", "Double-precision N-body simulation")

include("nbody_vec.jl")
@perf NBodyVec.nbody_vec() meta("nbody_vec", "A vectorized double-precision N-body simulation")

include("pidigits.jl")
@assert pidigits(1000) == 9216420198
@perf pidigits(1000) meta("pidigits", "Streaming arbitrary-precision arithmetic")

include("regex_dna.jl")
infile = rpath("regexdna-input.txt")
@perf regex_dna(infile) meta("regex_dna", "Match DNA 8-mers and substitute nucleotides for IUB codes")

include("revcomp.jl")
infile = rpath("revcomp-input.txt")
@perf revcomp(infile) meta("revcomp", "Read DNA sequences - write their reverse-complement")

include("spectralnorm.jl")
@perf spectralnorm() meta("spectralnorm", "Eigenvalue using the power method")

end # module
