
function integer_indexing(A)
    # index with two random integers
    nI, nJ = size(A)
    rI = 1:nI
    rJ = 1:nJ
    tmp = zero(eltype(A))
    for i in rand(rI, reps)
        for j in rand(rJ, rep)
            tmp += A[i,j]
        end
    end
    tmp
end

function row_indexing(A, rowinds)
    # index rows with rowinds and columns with a random integer
    nI, nJ = size(A)
    rI = 1:nI
    rJ = 1:nJ
    tmp = zero(eltype(A))
    for j in rand(rJ, reps)
        tmp += sum(A[rowinds,j])
    end
    tmp
end

function col_indexing(A, colinds)
    # index rows with a random integer and columns with colinds
    nI, nJ = size(A)
    rI = 1:nI
    rJ = 1:nJ
    tmp = zero(eltype(A))
    for i in rand(rI, div(reps,10) )
        tmp += sum(A[i,colinds])
    end
    tmp
end

function row_col_indexing(A, rowinds, colinds)
    # index rows with rowinds and columns with colinds
    # we need:
    (maximum(rowinds)+rep < size(A,1) && maximum(colinds)+rep < size(A, 2)) || error("bad rowinds or colinds")
    nI, nJ = size(A)
    rI = 1:nI
    rJ = 1:nJ
    for i in 1:10
        for j in 1:10
            tmp2 = A[rowinds.+i, colinds.+j]
        end
    end
end

function one_arg_indexing(A, lininds)
    # This is for 1d-indexing and indexing with one array of logicals.
    # Both return a nx1 sparse matrix.
    tmp = zero(eltype(A))
    if isa(eltype(A), Bool)
        tmp = sum(A[lininds])
    else
        for i in 1:rep
            tmp += sum(A[lininds])
        end
    end
    tmp
end
