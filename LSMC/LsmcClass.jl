mutable struct LsmcSpec
    option::Option
    numSteps::Int64
    numSims::Int64

    δ_t::Float64
    disc::Float64

    function LsmcSpec(option::Option, numSteps::Int64, numSims::Int64)
        this = new()

        this.option = option
        this.numSteps = numSteps
        this.numSims = numSims

        this.δ_t = option.T / numSteps
        this.disc = exp(-option.r * this.δ_t)

        return this
    end
end

struct LsmcResult
    price::Float64
    stock::Array{Float64,2}
    payoff::Array{Float64,2}
    execution::Array{Float64,2}
end
