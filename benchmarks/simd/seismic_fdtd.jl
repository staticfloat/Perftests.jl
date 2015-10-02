# This file is a part of Julia. License is MIT: http://julialang.org/license

# Finite-difference time-domain seismic simulation in 2D using a staggered grid.
# The intent is to test performance of @simd on the inner loop of a 2D loop nest.
#
# If @simd ever supports forward-lexical dependences, then the kernels in updateV
# and updateU can be merged.

# Update velocity component fields Vx and Vy
function updateV( irange, jrange, U, Vx, Vy, A )
    for j in jrange
        @simd for i in irange
            @inbounds begin
                Vx[i,j] += (A[i,j+1]+A[i,j])*(U[i,j+1]-U[i,j])
                Vy[i,j] += (A[i+1,j]+A[i,j])*(U[i+1,j]-U[i,j])
            end
        end
    end
end

# Update pressure field U
function updateU( irange, jrange, U, Vx, Vy, B )
    for j in jrange
        @simd for i in irange
            @inbounds begin
                U[i,j] += B[i,j]*((Vx[i,j]-Vx[i,j-1]) + (Vy[i,j]-Vy[i-1,j]))
            end
        end
    end
end

# Alternate updates for given number of steps
function flog_fdtd( steps, U, Vx, Vy, A, B )
    m,n = size(U)
    for k=1:steps
         updateV(2:m-1,2:n-1,U,Vx,Vy,A)
         updateU(2:m-1,2:n-1,U,Vx,Vy,B)
    end
end
