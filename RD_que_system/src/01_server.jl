include("00_arriver.jl")


"""
Creating base for servers.
"""
mutable struct ServerBase
    n_servers::Int64
    queue_overload::Int64

    current_traffic::Vector{Dict{String, Any}}
    current_queue:: Vector{Dict{String, Any}}

    function ServerBase(
        n_servers::Int64,
        queue_overload::Int64,
        current_traffic::Vector{Dict{String, Any}} = Dict{String, Any}[],
        current_queue::Vector{Dict{String, Any}} = Dict{String, Any}[],
        # current_traffic::Vector{Dict{String, Any}},
        # current_queue::Vector{Dict{String, Any}},
        )
        return new(
            n_servers,
            queue_overload,
            current_traffic,
            current_queue,
        )
    end
end 


"""
Function to check if server is busy
"""
function check_busy(self::ServerBase)
    if length(self.current_traffic) < self.n_servers
        return false
    else
        return true
    end
end


"""
Function for updating the state 
of the server base
"""
function update_traffic(
    self::ServerBase,
    add_true::Bool,
    change::Dict{String, Any},
    )
    if add_true == true
        push!(self.current_traffic, change)
    else
        id = change["id"]
        for j in 1:length(self.current_traffic)
            if self.current_traffic[j]["id"] == id
                deleteat!(self.current_traffic, j)
                break
            end
        end
    end
end


"""
Function for updating the state
of the server base
"""
function update_queue(
    self::ServerBase,
    add_true::Bool,
    change::Dict{String, Any}
    )
    if add_true == true
        push!(self.current_queue, deepcopy(change))
    else
        popfirst!(self.current_queue)
    end
end