

interarrival_times = [1, 0.3, 0.2]
service_times = [0.4, 0.8, 0.9]

cum_ia_times = []
cum_s_times = []

for i in 1:length(interarrival_times)
    if i ==1
        push!(cum_ia_times, deepcopy(interarrival_times[i]))
        push!(cum_s_times, deepcopy(service_times[i]+=interarrival_times[i]))
    else
        push!(cum_ia_times, deepcopy(interarrival_times[i] + cum_ia_times[i-1]))
        push!(cum_s_times, deepcopy(service_times[i] + cum_s_times[i-1]))
    end
end
println(cum_ia_times)
println(cum_s_times)

for i in 1:length(cum_ia_times)
    alfa = cum_s_times[i]
    bravo = cum_ia_times[]
    # cheeck if there are other cum_ia_times, 
    # which are not the same index or lower
    #take these the s time and subtract with all second comment times. 

end

# for hver som går inn
#   når hver går ut:
#       sjekk alle som har ventet i kø i mellomtiden //ventetid
#       
#