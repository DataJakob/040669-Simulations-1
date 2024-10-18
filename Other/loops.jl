println("---Program start---")
println("Just applying the simple loops")

myList = ["a","b","c","d"]

println("--For loop--")
function ForLoop(List::Vector{String})
    println(List)
    for i in 1:length(List)
        println(List[i])
    end
end
ForLoop(myList)


println("--Foreach loop--")
function ForeachLoop(List::Vector{String})
    for i in eachindex(List)
        println(List[i])
    end
end
ForeachLoop(myList)


println("--While loop--")
function WhileLoop(List::Vector{String})
    stop = length(List)
    i = 1
    while i <=stop
        println(myList[i])
        i += 1
    end
end
WhileLoop(myList)
println("----Program ended----")