
using BenchmarkTools
using Base.Threads
using Distributed

###############
# test 1
a = zeros(10)

@threads for i = 1:10
   a[i] = threadid()
end

################
# test 2
i = Atomic{Int}(0)
ids = zeros(4)
old_is = zeros(4)

@threads for id in 1:4
   old_is[id] = atomic_add!(i, id)
   ids[id] = id
end

################
# test 3 race condition
acc = Ref(0)
@threads for i in 1:1000
   acc[] += 1
end
println(acc[])


function test()
   acc = Atomic{Int64}(0)
   Threads.@threads for i in 1:1000
      atomic_add!(acc, 1)
   end
end

function test1()
   acc = 0.0
   for i in 1:1000
      acc += 1
   end
end
@time test()
@time test1()

##############
# simd test
function axpy(a,x,y)
   @simd for i=1:length(x)
      @inbounds y[i] += a*x[i]
   end
end

function axpy2(a,x,y)
   for i=1:length(x)
      y[i] += a*x[i]
   end
end

x = collect(1:10^7)
y = zeros(10^7)
a = 2.5
@time axpy(a,x,y)
@time axpy2(a,x,y)
@btime axpy(a,x,y)
@btime axpy2(a,x,y)

#####################
# parallel test with imbounds
function myadd(x,y)
   @inbounds for i=1:length(x)
      y[i] += x[i]
   end
end

function myaddt(x,y)
   @inbounds @threads for i=1:length(x)
      y[i] += x[i]
   end
end

@everywhere function myadde(x, y)
   @inbounds for i=1:length(x)
      y[i] += x[i]
   end
end

x = collect(1:10^8)
y = collect(1:10^8) .+ 1
@time myadd(x,y)
@time myaddt(x,y)
@time myadde(x,y)
@btime myadd(x,y)
@btime myaddt(x,y)
@btime myadde(x,y)

#######################
# parallel test for rng
using BenchmarkTools
import Base.Threads
using Distributed

function myrng(num)
   @inbounds for i=1:num
      randn()
   end
end

function myrngt(num)
   rng = Random.MersenneTwister(1234)
   rngs = [rng; accumulate(Future.randjump, fill(big(10)^20, Threads.nthreads()-1), init=rng)]

   @inbounds Threads.@threads for i=1:num
      randn(rngs[Threads.threadid()])
   end
end

function myrngts(num)
   # rng = Random.MersenneTwister(1234)
   # rngs = [rng; accumulate(Future.randjump, fill(big(10)^20, Threads.nthreads()-1), init=rng)]

   @inbounds Threads.@threads for i=1:num
      randn()
   end
end

@everywhere function myrnge(num)
   @inbounds for i=1:num
      randn()
   end
end

num = 10^8
@time myrng(num)
@btime myrng(num)
@time myrnge(num)
@btime myrnge(num)
@time myrngt(num)
@btime myrngt(num)
@time myrngts(num)
@btime myrngts(num)
