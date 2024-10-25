using Distributions
using Random


function Distribution_Generator(
    distance_type::String,
    mu::Float64,
    sigma::Float64,
    n_arrivals::Int64,
    n_arrays::Int64,
    constant::Float64,
    random_seed::Int64,
    )
    """
    Calculate the cumulative times for interarrival
    and service times. 
    """

    Random.seed!(42)
    distribution_list = Vector{Vector{Float64}}()

    normal_dist = Normal(mu, sigma)
    erlang_dist = Gamma(mu, 1/sigma)
    exponential_dist = Exponential(mu)
    poisson_dist = Poisson(mu)

    for i in 1:n_arrays
        Random.seed!(random_seed+=i)
        n_th_distribution = Vector{Float64}()
        for j in 1:n_arrivals
            if distance_type == "Normal" 
                jtem =  rand(normal_dist)
            elseif distance_type == "Erlang"
                jtem = rand(erlang_dist)
            elseif distance_type == "Exponential"
                jtem = rand(exponential_dist)
            elseif distance_type == "Poisson"
                jtem = rand(poisson_dist)
            else 
                println("Invalid distribution name")
                break
            end
            if i == 1
                jtem += constant
            end
            push!(n_th_distribution, jtem)
        end
        push!(distribution_list, n_th_distribution)
    end
    return distribution_list
end


function Calculate_ia_and_s_times(
    ia_times::Vector{Vector{Float64}}, 
    s_times::Vector{Vector{Float64}}
    )
    """ 
    Calculate the cumulative times for 
    interarrival and serivces times.
    """
    
    tot_cum_ia_times = Vector{Vector{Float64}}()
    tot_cum_s_times = Vector{Vector{Float64}}()

    for i in 1:length(ia_times)
        cum_ia_times = [deepcopy(ia_times[i][1])]
        cum_s_times = [deepcopy(s_times[i][1]+ia_times[i][1])]  

        work_ia = ia_times[i]
        work_s = s_times[i]
        for j in 2:length(ia_times[1])
            push!(cum_ia_times, deepcopy(work_ia[j] + cum_ia_times[j-1]))
            alt_1 = cum_s_times[j-1] + work_s[j]
            alt_2 = cum_ia_times[j] + work_s[j]
            relevant_time = max(alt_1, alt_2)
            push!(cum_s_times, relevant_time)
        end
        push!(tot_cum_ia_times, cum_ia_times)
        push!(tot_cum_s_times, cum_s_times)    
    end
    return [tot_cum_ia_times, tot_cum_s_times]
end




mutable struct ServerBase
    n_servers::Int64
    current_traffic::Int64
    busy::Bool

    """
    Creating base for servers.
    """

    function ServerBase(
        n_servers::Int64,
        current_traffic::Int64,
        busy::Bool,
        )
        return new(n_servers,
            current_traffic,
            busy)
    end
end 


function update_traffic(
    self::ServerBase,
    change::Int64,
    )

    """
    Creating a function to update the state 
    of the server base
    """

    if change == 1
        self.current_traffic += 1
        if self.current_traffic == self.n_servers
            self.busy = true
        else
            self.busy = false
        end
    else
        self.current_traffic -= 1
        if self.current_traffic < 0
            self.current_traffic = 0
        end
        self.busy = false
    end
end