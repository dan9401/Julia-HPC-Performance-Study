
# not used, used for pricing with entire grid, not necessary
function pricer(numSteps, numSims, option, poGrid_final)
    S, K, r, σ, T = option.S, option.K, option.r, option.σ, option.T
    poGrid = poGrid_final
    δ_t = T / numSteps
    psum = 0.0
    for i in 1:numSteps+1
        psum += sum(poGrid[:,numSteps+2-i] .* exp(-r * δ_t * (numSteps+1-i)))
    end
    price = psum / numSims
    #price = sum(sum(poGrid_final, dims = 1))
    print(price)
    return price
end

# not used, need to explicitly input i, could be put into linReg function after change
function errorDetect(X)
    try
        inv(X' * X)
    catch e
        println(det(X' * X))
        display(X' * X)
        display(X)
    end
end






#Error Catching
# try
#     inv(X'*X)
# catch e
#     display(X' * X)
#     display(X)
#     display(opGrid[:,numSteps-i+1])
#     println(det(X' * X))
#     println(i)
#     print(sum(mask), numSims)
# end

include("Option.jl")
function euroMCbench(option::Option, numSims::Int64)
    S, K, r, σ, T = option.S, option.K, option.r, option.σ, option.T
    S_adj = S * exp((r - σ^2.0/2.0)*T)
    psum = 0.0

    for i in 1:numSims
        St = S_adj * exp(σ*sqrt(T)*randn())
        prem = St-K
        psum += ifelse(prem > 0.0, prem, 0.0)
    end

    price = psum / numSims * exp(-r*T)
    return price
end

function euroMCbench2(option::Option, numSims::Int64)
    S, K, r, σ, T = option.S, option.K, option.r, option.σ, option.T
    S_adj = S * exp((r - σ^2.0/2.0)*T)
    psum = 0.0

    for i in 1:numSims
        St = S_adj * exp(σ*sqrt(T)*randn())
        prem = St-K
        psum += ifelse(prem > 0.0, prem, 0.0)
    end

    price = psum / numSims * exp(-r*T)
    return price
end

using BenchmarkTools
@btime euroCall(10^8, 100.0, 110.0, 0.05, 0.2, 1.0)
