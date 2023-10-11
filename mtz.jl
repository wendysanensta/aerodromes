# ---------------------------------------------------------------
# Sequential formulation (MTZ)
# ---------------------------------------------------------------
using JuMP, Gurobi
include("lecture_distances.jl")
include("print path.jl")

file_path = "C:/Users/wen21/Documents/SOD321 Projet/instance_20_3.txt"
n,d,f,Amin,Nr,R,regions,coords,D = readInstance(file_path)

m = Model(Gurobi.Optimizer)
# Déclaration variables : xijk = 1 si l'arc orienté de i vers j existe (0 sinon)
@variable(m, x[1:n,1:n], Bin)
@variable(m, t[1:n] >= 0)
@variable(m, y[1:n], Bin) # qui indique si le sommet i fait partie du chemin
@variable(m, r[1:Nr], Bin) # qui indique si la région i a été visitée

@objective(m, Min,  sum(D[i,j]*x[i, j] for i in 1:n, j in 1:n))

@constraint(m, sum(x[d,j] for j in 1:n) - sum(x[j,d] for j in 1:n) == 1)
@constraint(m, sum(x[f,j] for j in 1:n) - sum(x[j,f] for j in 1:n) == -1)
for i in 1:n
    if (i!=d)&&(i!=f)
        @constraint(m, sum(x[i,j] for j in 1:n) - sum(x[j,i] for j in 1:n) == 0)
    end
end

#les deux contraintes ci-dessous garantissent qu'on ne passe qu'une fois par chaque sommet
#@constraint(m, [i in 1:n], sum(x[i,j] for j in 1:n)<=1) # on ne peut pas avoir plus d'un arc sortant par sommet
#@constraint(m, [j in 1:n], sum(x[i,j] for i in 1:n)<=1) # on ne peut pas avoir plus d'un arc entrant par sommet

@constraint(m, [i in 1:n], x[i,i]==0)


# mtz formulation
for i in 1:n
    for j in 1:n
        if (i!=d)&&(j!=f)
            @constraint(m, t[j]>=t[i] + 1 + (n-1)*(x[i,j]-1))
        end
    end
end

# contrainte sur y : y[i]==1 si l'arc est emprunté
@constraint(m, [i in 1:n], y[i] == sum(x[i,j] for j in 1:n) )
@constraint(m, y[f]==1)

# chaque région doit être visitée au moins 1 fois
@constraint(m, [i in 1:Nr, j in regions[i]], r[i] >= y[j])
@constraint(m, [i in 1:Nr], r[i] == 1)

# l'avion de peut pas parcourir plus de la distance R sur une arête
@constraint(m,[i in 1:n, j in 1:n], D[i,j]*x[i,j]<= R)

# l'avion doit visiter au moins Amin aerodromes
@constraint(m, sum(y[i] for i in 1:n) >= Amin)

JuMP.optimize!(m)
obj_value = JuMP.objective_value(m)
println("Objective value = ", obj_value)
println(JuMP.termination_status(m))


for i in 1:n
    println("y[$i] = ", value(y[i]))
end


for i in 1:n
    for j in 1:n
        if (value(x[i,j])==1)
            println("x[$i, $j] = 1")
        end
    end
end

printPath(x,d,f,Amin)