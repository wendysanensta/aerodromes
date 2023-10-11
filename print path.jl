##### print path 

function printPath(x, d, f, Amin)
    local nb_parcouru = 0
    local current_node = d
    print("départ : ", d)

    while (nb_parcouru <= Amin) || (current_node != f)
        local next_node = 1

        while (next_node <= size(x, 2)) && (value(x[current_node, next_node]) != 1)
            next_node = next_node + 1
        end

        if next_node > size(x, 2)
            print("No valid path found.")
            return
        end

        print(" -> ", next_node)
        current_node = next_node
        nb_parcouru = nb_parcouru + 1
    end
end