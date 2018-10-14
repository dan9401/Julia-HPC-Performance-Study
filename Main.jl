include("European/EuroBS.jl")
include("European/EuroMC.jl")
include("LSMC/LSMC.jl")

numSteps = 100
numSims = 100000
testCall = Option(100.0, 110.0, 0.05, 0.2, 1, CALL)
testPut = Option(100.0, 110.0, 0.06, 0.2, 1, PUT)

println("Pricing European Option by B-S Formula: ")
println("Test CALL Option: ", euroBS(testCall))
println("Test PUT Option: ", euroBS(testPut))

println("Pricing European Option by Monte Carlo Simulation: ")
println("Test CALL Option: ", euroMC(testCall, numSims))
println("Test PUT Option: ", euroMC(testPut, numSims))

println("Pricing American Option by Least Squares Monte Carlo: ")
lsmcCall = LsmcSpec(testCall, numSteps, numSims)
lsmcPut = LsmcSpec(testPut, numSteps, numSims)
resCall= lsmcAmerican(lsmcCall)
resPut = lsmcAmerican(lsmcPut)
println("Call: ", resCall.price)
println("Put: ", resPut.price)
