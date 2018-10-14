include("Option.jl")

function euroMC(option::Option, numSims::Int64)
    S, K, r, σ, T, corp = option.S, option.K, option.r, option.σ, option.T, option.corp
    S_adj = S * exp((r - σ^2.0/2.0)*T)
    psum = 0.0

    for i in 1:numSims
        St = S_adj * exp(σ*sqrt(T)*randn())
        prem = ifelse(corp == CALL, St - K, K - St)
        psum += ifelse(prem > 0.0, prem, 0.0)
    end

    price = psum / numSims * exp(-r*T)
    return price
end
