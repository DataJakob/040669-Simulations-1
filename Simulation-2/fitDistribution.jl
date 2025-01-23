using CSV
using DataFrames
using Plots
using Distributions
using Optim
using NLopt

# Reading a csv file, and plotting the distribution.
df =  CSV.read("Input_Museum.csv", DataFrame; header=["Obs", "SelTime"])

function log_likelihood(params, data)
    
    mu1, sig1,  mu2, sig2, w1 = params

    log_dist = Normal(mu1,sig1)
    nor_dist = Normal(mu2,sig2)

    log_likelihood =  0.0

    log_likelihood =   sum(log(w1*pdf(log_dist, x) + (1-w1) * pdf(nor_dist,x)) for x in data)
    return - log_likelihood
end

# w1,  mu1, sig1, mu2, sig2
my_params = [28.0, 5.0, 65.0, 15.0, 0.5]
my_data = df.SelTime

function fit_mixture_model(my_params, data)
    lower_bounds = [0, 0, 0, 0, 0.0]  # Lower bounds 
    upper_bounds = [Inf, Inf, Inf, Inf, 1.0]  # Upper bounds 

    opt = NLopt.Opt(:LN_BOBYQA, 5)
    NLopt.lower_bounds!(opt, lower_bounds)
    NLopt.upper_bounds!(opt, upper_bounds)
    NLopt.min_objective!(opt, (params, grad) -> log_likelihood(params, data))
    result = NLopt.optimize(opt, my_params)
    return result[2]
end

fitted_params = fit_mixture_model(my_params, my_data)
println("Fitted parameters: ", fitted_params)

histogram(df.SelTime, bins=25, color=:green, title="Distribution of desired times", xlabel="Time periods", ylabel="Frequency")
