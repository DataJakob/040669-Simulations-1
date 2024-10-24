"""
Subquestion 1:

A random number generator should have a full period.
This invovles that the generator produces all numbers in its sequence, before it starts to repeat itself. 
This is important, because then the generator won't be biased towards some specific numbers. 
"""

"""
Subquestion 2:

Giving a random number generator a seed gives the program the ability to reproduce it's result time over time. 
This makes it possible for other scientist and interested in producing the same results.
Another way one can frame it, is by saying that you are going to do a procedure  the n-th random way.
"""

"""
Subquestion 3:

If you were to not use a seed then you would get new results
"""
using Random

function random_integer()
    return rand(1:100)
end
ri = random_integer()
println("My random number is: $ri")
# Everyting between 1 and 100

Random.seed!(42)
function nth_random_integer()
    return rand(1:100)
end
nth_ri = nth_random_integer()
println("My n-th random integer is: $nth_ri") 
#Usually 63