# First homework


# Array with various fruit, three are cut and one is not
whole_fruits = [Dict("fruit"=>"apple", "weight"=>180, "cut"=> false),
    Dict("fruit"=>"melon", "weight"=>2350, "cut"=> false),
    Dict("fruit"=>"blueberry", "weight"=>3, "cut"=> true),
    Dict("fruit"=>"carrot", "weight"=>100, "cut"=> false)]

# Empty array which shall hold fruits that have been cut
cut_fruits = []



# Creating a for loop from 1 to length of array.
println("Start operation:")
for i in 1:length(whole_fruits)

    # Save each item in the array
    new_item = whole_fruits[i]

    # If item is not cut; it will get cut and appended to the new array.
    if new_item["cut"] == false
        new_item["cut"] = true
        println("Cutting ", whole_fruits[i]["fruit"],".")
        push!(cut_fruits, deepcopy(new_item))
    else
        # Fruit is already cut and being appended to the new array.
        println("Not cutting ", new_item["fruit"],".")
        push!(cut_fruits, deepcopy(new_item))
    end
end
println("End operation.")

# Print the final result
println("\nFinal result:")
println(cut_fruits)
