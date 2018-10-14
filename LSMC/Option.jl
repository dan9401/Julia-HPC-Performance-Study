@enum OptionType CALL = 1 PUT = 2

struct Option
    S::Float64
    K::Float64
    r::Float64
    σ::Float64
    T::Float64
    corp::OptionType
end
