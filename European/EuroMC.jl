include("Option.jl")
import Random
import Future
import Base.Threads

function euroMC(option::Option, numSims::Int64)
    S, K, r, σ, T, corp = option.S, option.K, option.r, option.σ, option.T, option.corp
    S_adj = S * exp((r - σ^2.0/2.0)*T)
    psum = 0.0

    if corp == CALL
        for i in 1:numSims
            St = S_adj * exp(σ*sqrt(T)*randn())
            p = ifelse(St - K > 0.0, St - K, 0.0)
            psum += p
        end
    elseif corp == PUT
        for i in 1:numSims
            St = S_adj * exp(σ*sqrt(T)*randn())
            p = ifelse(St - K > 0.0, St - K, 0.0)
            psum += p
        end
    end

    price = psum / numSims * exp(-r*T)
    return price
end

function euroMCp(option::Option, numSims::Int64)
    S, K, r, σ, T, corp = option.S, option.K, option.r, option.σ, option.T, option.corp
    S_adj = S * exp((r - σ^2.0/2.0)*T)
    psum = Threads.Atomic{Float64}(0)

    #rng_seed =UInt32[0xbd8e7dc4,0x0d00f383,0xdccee4c9,0x553afb99];
    rng_seed = 22
    rng = Random.MersenneTwister(rng_seed)
    rngs = [rng; accumulate(Future.randjump, fill(big(10)^20, Threads.nthreads()-1), init=rng)]
    n = Threads.nthreads()

    if corp == CALL
        Threads.@threads for i in 1:n
            tsum = 0.0
            for i in 1:(numSims/n)
                St = S_adj * exp(σ*sqrt(T)*randn(rngs[Threads.threadid()]))
                p = ifelse(St - K > 0.0, St - K, 0.0)
                tsum += p
            end
            Threads.atomic_add!(psum, tsum)
        end
    elseif corp == PUT
        Threads.@threads for i in 1:n
            tsum = 0.0
            for i in 1:(numSims/n)
                St = S_adj * exp(σ*sqrt(T)*randn(rngs[Threads.threadid()]))
                p = ifelse(K - St > 0.0, K - St, 0.0)
                tsum += p
            end
            Threads.atomic_add!(psum, tsum)
        end
    end

    price = psum[] / numSims * exp(-r*T)
    return price
end
