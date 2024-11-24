using Distributions
using Random
using JSON



# """
# Calculate the cumulative times for interarrival
# and service times. 
# """
# function Distribution_Generator(
#     distance_type::String,
#     mu::Float64,
#     sigma::Float64,
#     n_arrivals::Int64,
#     n_arrays::Int64,
#     constant::Float64,
#     random_seed::Int64,
#     )
#     Random.seed!(42)
#     distribution_list = Vector{Vector{Tuple{String, Float64}}}()

#     normal_dist = Normal(mu, sigma)
#     erlang_dist = Gamma(mu, 1/sigma)
#     exponential_dist = Exponential(mu)
#     poisson_dist = Poisson(mu)

#     for i in 1:n_arrays
#         Random.seed!(random_seed+=i)
#         n_th_distribution = Vector{Tuple{ String,Float64}}()
#         for j in 1:n_arrivals
#             id_string = string(Char('a'+i-1)) * string(j) 

#             if distance_type == "Normal" 
#                 jtem =  rand(normal_dist)
#             elseif distance_type == "Erlang"
#                 jtem = rand(erlang_dist)
#             elseif distance_type == "Exponential"
#                 jtem = rand(exponential_dist)
#             elseif distance_type == "Poisson"
#                 jtem = rand(poisson_dist)
#             else 
#                 println("Invalid distribution name")
#                 break
#             end
#             if i == 1
#                 jtem += constant
#             end
#             push!(n_th_distribution, (id_string, jtem))
#         end
#         push!(distribution_list, n_th_distribution)
#     end
#     return distribution_list
# end



# """ 
# Calculate the cumulative times for 
# interarrival and serivces times.
# """
# function Calculate_cum_ia_times(
#     ia_times::Vector{Vector{Tuple{String,Float64}}}, 
#     )  

#     tot_cum_ia_times = Vector{Vector{Tuple{String,Float64}}}()
#     for i in 1:length(ia_times)
#         work_ia = ia_times[i]
#         cum_ia_times = [(deepcopy(work_ia[1][1]), deepcopy(work_ia[1][2]))]
#         for j in 2:length(ia_times[1])
#             push!(cum_ia_times, (deepcopy(work_ia[j][1]), deepcopy(work_ia[j][2] + cum_ia_times[j-1][2])))
#         end
#         push!(tot_cum_ia_times, cum_ia_times)
#     end
#     return tot_cum_ia_times
# end

using Distributions

function calculate_ia_and_s(
    n_line::Int64,
    n_time::Float64,
    n_arr_hour::Float64,
    n_ser_hour::Float64,
    randomness::Int64,
    )

    # n_arr_rate = n_arr_hour/60
    arrival =  Vector{Vector{Tuple{String, Float64}}}()
    cum_arrival = Vector{Vector{Tuple{String, Float64}}}()
    service = Vector{Vector{Tuple{String, Float64}}}()

    for i in 1:n_line
        Random.seed!(randomness+i)
        single_arrival = rand(Exponential(1/n_arr_hour), Int(n_time*n_arr_hour))
        single_cum_arrival = cumsum(single_arrival)
        single_service = rand(Exponential(1/n_ser_hour), Int(n_time*n_arr_hour))

        single_arrival_with_ids = [
            (string(Char('a' + i - 1)) * string(j), single_arrival[j]) for j in 1:length(single_arrival)
        ]

        # Create DataEntry for cumulative arrival times with unique IDs
        single_cum_arrival_with_ids = [
            (string(Char('a' + i - 1)) * string(j), single_cum_arrival[j]) for j in 1:length(single_cum_arrival)
        ]

        # Create DataEntry for service times with unique IDs
        single_service_with_ids = [
            (string(Char('a' + i - 1)) * string(j), single_service[j]) for j in 1:length(single_service)
        ]

        # Store these in the respective vectors
        push!(arrival, single_arrival_with_ids)
        push!(cum_arrival, single_cum_arrival_with_ids)
        push!(service, single_service_with_ids)
    end

    return [arrival, cum_arrival, service]
end

"""
Create a mutable structure to store data
"""
mutable struct DataEntry
    id::String
    initial_line::Int64
    ia_time::Float64
    cum_ia_time::Float64
    s_time::Float64
    final_line::Int64
    w_time::Float64
    dep_time::Float64
end



"""
Use interarrival, service and cumulative interarrival times
to store the input data into a json file. 
"""
function Data_to_json(
    ia_times::Vector{Vector{Tuple{String,Float64}}}, 
    s_times::Vector{Vector{Tuple{String,Float64}}}, 
    cum_ia_times::Vector{Vector{Tuple{String,Float64}}}
    )
    data = Vector{Vector{DataEntry}}()
    for i in 1:length(cum_ia_times)
        sub_data = Vector{DataEntry}()
        for j in 1:length(cum_ia_times[1])
            sel_id = DataEntry(
                cum_ia_times[i][j][1],
                i,
                ia_times[i][j][2],
                cum_ia_times[i][j][2],
                s_times[i][j][2],
                0,
                0.0,
                0.0
                )
            push!(sub_data,deepcopy(sel_id))
        end
        push!(data, sub_data)
    end
    json_string = JSON.json(data)
    src_code_dir = @__DIR__
    output_file_path = joinpath(src_code_dir, "../data/output.json")
    open(output_file_path, "w") do file
        write(file, json_string)
    end
end
# println(@__DIR__)