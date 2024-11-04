lambda = 4/40   # Rate of ovens arriving per hour
mu = 1/7        # Rate of ovens fixes per hour
p = lambda / mu # Utilization rate


# M/M/1
L = lambda/(mu-lambda)
println("Task 2a, avg. packages in system: ", L)

Lq = lambda*lambda/(mu*(mu-lambda))
println("\nTask 2b, avg. packages in queue: ", Lq)

Wq = lambda/(mu*(mu-lambda))
println("\nTask 2c,  avg. waiting time in queue: ", Wq)

W = 1/(mu-lambda)
println("\nTask 2d, total time in queue: ", W)

println("\nThe effecitve arrival rate is 0.1")