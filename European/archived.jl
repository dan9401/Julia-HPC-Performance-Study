using Profile
Profile.clear()
@profile euroMCp(testCall, 10^5)
Profile.print()

using Pkg
Pkg.add("ProfileView")
Pkg.build("Cairo")
using ProfileView
ProfileView.view()

# using Pkg
# Pkg.add("Distributions")
# import Distributed
using Distributed

function euroMCta(option::Option, numSims::Int64)
    S, K, r, σ, T, corp = option.S, option.K, option.r, option.σ, option.T, option.corp
    S_adj = S * exp((r - σ^2.0/2.0)*T)
    St = zeros(numSims)

    Threads.@threads for i in 1:numSims
        St[i] = S_adj * exp(σ*sqrt(T)*randn())
    end

    psum = 0.0
    if corp == CALL
        psum = sum(ifelse.(St .- K .> 0.0, St .- K, 0.0))
    elseif corp == PUT
        psum =  sum(ifelse.(K .- St .> 0.0, K .- St, 0.0))
    end

    price = psum / numSims * exp(-r*T)
    return price
end

function euroMCa(option::Option, numSims::Int64)
    S, K, r, σ, T, corp = option.S, option.K, option.r, option.σ, option.T, option.corp
    S_adj = S * exp((r - σ^2.0/2.0)*T)
    St = zeros(numSims)

    for i in 1:numSims
        St[i] = S_adj * exp(σ*sqrt(T)*randn())
    end

    psum = 0.0
    if corp == CALL
        psum = sum(ifelse.(St .- K .> 0.0, St .- K, 0.0))
    elseif corp == PUT
        psum =  sum(ifelse.(K .- St .> 0.0, K .- St, 0.0))
    end

    price = psum / numSims * exp(-r*T)
    return price
end

@everywhere function euroMCe(option::Option, numSims::Int64)
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
