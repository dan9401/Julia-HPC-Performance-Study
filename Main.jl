include("European/EuroBS.jl")
include("European/EuroMC.jl")
include("LSMC/LSMC.jl")

testCall = Option(100.0, 110.0, 0.05, 0.2, 1, CALL)
testPut = Option(100.0, 110.0, 0.06, 0.2, 1, PUT)

println("Pricing European Option by B-S Formula(euroBS): ")
println("Test CALL Option: ", euroBS(testCall))
println("Test PUT Option: ", euroBS(testPut), "\n")

numSims = 10^7
println("Pricing European Option by Monte Carlo Simulation(euroMC): ")
println("Test CALL Option: ", euroMC(testCall, numSims))
println("Test PUT Option: ", euroMC(testPut, numSims), "\n")

numSteps = 100
numSims = 10^6
println("Pricing American Option by Least Squares Monte Carlo(): ")
lsmcCall = LsmcSpec(testCall, numSteps, numSims)
lsmcPut = LsmcSpec(testPut, numSteps, numSims)
resCall= lsmcAmerican(lsmcCall)
resPut = lsmcAmerican(lsmcPut)
println("LSMC American Call: ", resCall.price)
println("LSMC American Put: ", resPut.price, "\n", "\n")


println("Threaded time test for euroMC: ")
import BenchmarkTools
numSims = 10^8
euroMC(testCall, numSims); euroMCp(testCall, numSims);
BenchmarkTools.@btime euroMC(testCall, numSims)
BenchmarkTools.@btime euroMCp(testCall, numSims)


println("\n", "Threaded time test for LSMC: ")
lsmcAmerican(lsmcCall); lsmcAmerican(lsmcCall);
BenchmarkTools.@btime lsmcAmerican(lsmcCall)
BenchmarkTools.@btime lsmcAmericanp(lsmcCall)
