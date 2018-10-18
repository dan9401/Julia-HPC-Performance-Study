include("../European/EuroMC.jl")

n = Threads.nthreads()
println("Pricing European Option by Monte Carlo Simulation with $n threads: ")
numSims = 10^8
testCall = Option(100.0, 110.0, 0.05, 0.2, 1, CALL)

println("Original Version: ")
@time euroMC(testCall, numSims)
@time euroMC(testCall, numSims)

println("Parallelized version:")
@time euroMCp(testCall, numSims)
@time euroMCp(testCall, numSims)

println("Non-threaded Version with allocation: ")
@time euroMCa(testCall, numSims)
@time euroMCa(testCall, numSims)

println("Threaded Version with allocation: ")
@time euroMCta(testCall, numSims)
@time euroMCta(testCall, numSims)

# println("Distributed Version: ")
# @time euroMCe(testCall, numSims)
# @time euroMCe(testCall, numSims)
