# main function
function lsmcAmerican(lsmc::LsmcSpec)
    sGrid, poGrid = priceGrid(lsmc)
    yVec, opGrid = linReg(lsmc, sGrid, poGrid)
    numSims = lsmc.numSims
    price = sum(yVec) / numSims
    return LsmcResult(price, sGrid, poGrid, opGrid)
end

# generating one path
function eqPriceGen(lsmc::LsmcSpec)
    option = lsmc.option
    S, r, σ= option.S, option.r, option.σ
    numSteps, numSims, δ_t = lsmc.numSteps, lsmc.numSims, lsmc.δ_t
    S_t = zeros(numSteps + 1)
    S_t[1] = S
    mult = exp((r - σ^2.0/2.0) * δ_t)

    for i in 1:numSteps
        S_t[i+1] = S_t[i] * mult * exp(σ * sqrt(δ_t) * randn())
    end

    return S_t
end

# price and payoff Grid
function priceGrid(lsmc::LsmcSpec)
    S, K = lsmc.option.S, lsmc.option.K
    numSteps, numSims = lsmc.numSteps, lsmc.numSims
    sGrid = poGrid = zeros(numSims, numSteps+1)

    for i in 1:numSims
        sGrid[i,:] = eqPriceGen(lsmc)
    end

    if lsmc.option.corp == PUT
        poGrid = ifelse.(K .- sGrid .> 0.0, K .- sGrid, 0.0)
    else lsmc.option.corp == CALL
        poGrid = ifelse.(sGrid .- K .> 0.0, sGrid .- K, 0.0) # for call
    end
    return (sGrid, poGrid)
end

# Regression and update process
function linReg(lsmc::LsmcSpec, sGrid, poGrid)
    numSteps, numSims, disc = lsmc.numSteps, lsmc.numSims, lsmc.disc
    yVec = poGrid[:, numSteps+1] .* disc
    opGrid = deepcopy(poGrid)

    for i in 1:(numSteps-1)
        mask = opGrid[:, numSteps-i+1] .> 0.0 # in the money op_n-1
        holdVec = zeros(numSims)

        if (sum(mask) >= 3)# & !(sGrid[1, numSteps-i+1] == sGrid[2, numSteps-i+1] == sGrid[3, numSteps-i+1]) # if full rank
            y = yVec[mask] # y = op_n * disc
            x = sGrid[mask, numSteps-i+1] # x = s_n-1
            X = hcat(ones(sum(mask)), x, x.^2) # X = [1, x, x^2]
            β = inv(X'*X)*X'*y # solve for β
            holdVec[mask] = X * β # [1:(end-1)] .+ β[end] # value if continue
        else
            holdVec = yVec .* disc # otherwise just discount 1 step
        end
        mask2 = opGrid[:, numSteps-i+1] .> holdVec # if execution value > continuation value
        opGrid[mask2, numSteps-i+2:end] .= 0.0 # execute, all the following steps on the path set to 0
        opGrid[mask2 .== false, numSteps-i+1] .= 0.0 # continue, do not execute at the step

        yVec[mask2] = opGrid[mask2, numSteps-i+1]
        yVec *= disc
    end

    return (yVec, opGrid)
end
