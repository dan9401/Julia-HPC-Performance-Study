import Distributions
include("Option.jl")

function euroBS(option::Option)
    S, K, r, σ, T, corp = option.S, option.K, option.r, option.σ, option.T, option.corp
    nd = Normal()
    d1 = (log(S/K) + (r + σ^2.0/2.0)*T) / σ / sqrt(T)
    d2 = d1 - σ * sqrt(T)
    if corp == CALL
        price = Distributions.cdf(nd, d1) * S - Distributions.cdf(nd, d2) * K * exp(-r * T)
    elseif corp == PUT
        price = - Distributions.cdf(nd, -d1) * S + Distributions.cdf(nd, -d2) * K * exp(-r * T)
    end
    return price
end
