function s(n)
    S = zeros(n)
    for i in 1:n
        S[i] = randn()
    end
    return S
end

function p(n)
    S = []
    for i in 1:n
        push!(S, randn())
    end
    # println(S)
end

function test(n)
    @time p(n)
    @time s(n)
end

struct Rate
    a::Float64
    b::Float64
end

struct Bond
    rate::Rate
    duration::Float64
    Iperiod::Float64
end

struct 😂
    😆::Float64
    😢::Float64
end

# sim
a = randn(10)*10
# boolean
b = a .> 5
# indices
c = cumsum(ones(length(a)))[b]

Base.iterate(op::bsOpt, state = 1) = state > 5 ? nothing : (getfield(op, state), state + 1)

function utest((S, K, r, σ, T)::bsOpt)

    return S + K
end

function unpackLSMC(lsmc::LSMC)
    return lsmc.bsOption.S, lsmc.bsOption.K, lsmc.bsOption.r, lsmc.bsOption.σ, lsmc.bsOption.T, numSims, numSteps
end


# x = somevector
# X = hcat(ones(length(x)), x, x.^2)
# inv(X'* X)
#
# Result: SingularException(3)



@enum optionType CALL = 1 PUT = 2

struct option
    S::Float64
    K::Float64
    r::Float64
    σ::Float64
    T::Float64

end

mutable struct lsmcSpec
    option::option
    numSteps::Int64
    numSims::Int64

    δ_t::Float64
    disc::Float64

    function lsmcSpec(option::option, numSteps::Int64, numSims::Int64)
        this = new()

        this.option = option
        this.numSteps = numSteps
        this.numSims = numSims

        this.δ_t = option.T / numSteps
        this.disc = exp(-option.r * this.δ_t)
        return this
    end
end
