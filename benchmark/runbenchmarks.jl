cd(dirname(@__FILE__))

# We include() <subdirectoryname>.jl from every subdirectory beneath us
subdirs = filter( subdir -> isfile(joinpath(subdir,"$subdir.jl")), readdir())

for subdir in subdirs
    include(joinpath(subdir,"$subdir.jl"))
end
