"""
This file contains an ad-hoc function to calculate the queue length of a line with the purpose of:

    - Checking the current queue length for each package that (arrives/depatures?) and 
        - compare it with the R5 queue lengths.

    - If queue length deviates more than  10% of the mean of the R5.
        - deviation in this case equals [0.9*mu, 1.1*mu].
    - Save the queue length and save it as a steady-state-event.
        - If not; save it, but say mark it as a none-steady-state event. 


Only suitable for calculating a one line queue.
"""

using Statistics

function Steady_State_Check()
    # Retrieve data
    src_code_dir = @__DIR__
    output_file_path = joinpath(src_code_dir, "../../RD_que_system/data/final_output.json")
    data = open(output_file_path, "r") do file
        JSON.parse(file)
    end


    # Vector for each line with respective server(s)
    tot_tot = Vector{Vector{}}()

    for i in 1:length(data)

        # Vector for each package in respective line.
        queue_length_tot =  Vector{Vector{Union{Float64, Bool}}}()

        for j in 1:length(data[1])

            # If the run was stopped prematurely; end calculations for this line
            if data[i][j]["dep_time"] == 0.0
                break
            end


            queue_length_sel = data[i][j]["w_time"]
            divider = data[i][j]["w_time"] + data[i][j]["cum_ia_time"]

            if j < 5.5
                alfa = true
                if j < 1.5
                    aggregated_queue_length = queue_length_sel/divider
                else 
                    aggregated_queue_length = (sum((y[1] for y in queue_length_tot); init=0) + queue_length_sel) / divider
                end
            else
                divider = data[i][j]["w_time"] + data[i][j]["cum_ia_time"] -  data[i][j-5]["w_time"] - data[i][j-5]["cum_ia_time"]
                latest_elements = queue_length_tot[end-4:end]
                mean_tot = sum((y[1] for y in latest_elements); init=0) / divider

                if aggregated_queue_length > mean_tot *1.1 ||aggregated_queue_length < mean_tot * 0.9
                    alfa = false
                else
                    alfa = true
                end
                println("mean", mean_tot)
                println("aggre", aggregated_queue_length)
            end
            to_be = [aggregated_queue_length, alfa]
            push!(queue_length_tot, to_be)
            
        end
        push!(tot_tot, queue_length_tot)
    end
    return tot_tot
end