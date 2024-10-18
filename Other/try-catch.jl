println("----Program started----")


function divide(a,b)
    try result = a/b 
        println("Result is $result")
    catch e
        println("Error is: $e")
    end
end
divide(4,"r")


println("----Program ended----")