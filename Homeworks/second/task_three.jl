mutable struct Customer
    id::Int
    X::Float64
    Y::Float64
    Served::Bool
    Vehicle::Int
end 

struct Depot
    Y::Float32
    X::Float32
end


cust1 = Customer(1,5,5,false,1)
cust2 = Customer(2,7,3,false,7)
cust3 = Customer(3,2,1,false,3)


maxDistance = 6.3
myDepot = Depot(3,4)
myCustomers = [cust1,cust2,cust3]


function serve_some_customer(myCustomers::Vector{Customer},
    maxDistance::Float64,
    myDepot::Depot)


    served_cust = Customer[]
    for i in 1:length(myCustomers)
        cust_i = myCustomers[i]
    
        cust_dist = sqrt((cust_i.X-myDepot.X)^2+(cust_i.Y-myDepot.Y)^2)
    
        if cust_dist < maxDistance
            if cust_i.id == cust_i.Vehicle
                cust_i.Served = true  
                println("Serving customer ", i, ".")
                push!(served_cust, deepcopy(cust_i)) 
            end
        end
    end
    return served_cust
end

result = serve_some_customer(myCustomers,maxDistance, myDepot)
println("\nThis is the result:\n",result)