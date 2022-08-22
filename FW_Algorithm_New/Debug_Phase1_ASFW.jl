include("./Basic_Functions.jl")
using .MyBasic
include("./Utility_Fun.jl")
using .Myutility_read
using .Myutility_AwayStep_Max   
using .Myutility_LineSearch
using GLPK
using JuMP
using LinearAlgebra



K=250
epsil_vec=[1e-2,1e-3,1e-4]
epsilName_vec=["e2","e3","e4"]  
epsil=epsil_vec[1]
epsilName=epsilName_vec[1]

for i in 2:2


output1_path="/Users/Mindy/Desktop/Debug/file"                                
cd(output1_path) 
mat_file=readdir()[i] #from 2

Instance=read_instance(mat_file)    #Go to the directory used to store output text files

output2_path="/Users/Mindy/Desktop/Debug/Text/Phase1_ASFW/"                                
cd(output2_path)


Q   = Instance["Q"]  
c   = Instance["c"]  
LB  = Instance["LB"]                #x >= LB, i.e. -x <=-LB
UB  = Instance["UB"]                # x <= UB
A   = Instance["A"]                 #A*x <=b
b   = Instance["b"]
Aeq = Instance["Aeq"]               #Aeq*x <=beq
beq = Instance["beq"]
n=length(LB)                          #The size of x, i.e, the number of variabels

Aieq=vcat(A, Matrix{Float64}(I, n, n), Matrix{Float64}(-I, n, n)) #Put all inequality constraints together
bieq=vcat(b, UB, -1*LB )

ninif_bieq=findall(x-> x >-Inf &&  x < Inf,bieq) #Find all elements in bieq which are not infinity

ninif_Aieq=Aieq[ninif_bieq,:]



open("$(mat_file)_$(epsilName).txt", "w") do file  
    
    
    model = Model(GLPK.Optimizer)         #Using GLPK Slover to slove LP

    model = Model(GLPK.Optimizer)            #Using GLPK Slover to slove LP
    @variable(model, LB[i] <= x[i=1:n] <= UB[i])
    @constraint(model, A * x .<= b)
    @constraint(model, Aeq * x .== beq)   
    @objective(model, Min, 0)
    optimize!(model)

       
        
    @objective(model, Min, 0)
    optimize!(model)

    write(file,"Using Phase I method to get a strating point: \n")
    write(file, "Describing a summary of the model: \n")
    write(file, "Termination Status: $(termination_status(model)) \n")
    write(file, "Primal Status: $(primal_status(model)) \n")
    write(file, "Message from the solver: $(raw_status(model) )\n")
    write(file, "Objective Value: $(objective_value(model) )\n")
    write(file, "\n")

    x_1=  value.(x) #KKT_StartPoint(Instance) #solveLP_StartPoint(Instance)#KKT_StartPoint(Instance)    ##      #solveLP_StartPoint(Instance)  #Get the starting point using solveLP_StartPoint or StartPoint_Two_PhaseSimplex
    global x_k=x_1                                         #Plug the initial point
    global iter=0                                          #Initialize the iteration number to be 0
    global rep=1                                           #Binary variabe to control if the while loop should be discountinued
    global opt_val=Inf                                     #Initialize the final objective function value to be 0
    global opt_sol=[]                                      #Initialize the final solution to be empty
    global Terminating=""  
   
    write(file,"The AwayStpe_FW_QP_Debug with Phase I is Starting:\n")      
    while rep==1

        #Get the number of iterations done so far: Remeber the first iteration is 1

        iter=iter+1    
                                                     
        write(file, "This is the iteration $(iter): \n")
           
       modelT = Model(GLPK.Optimizer)
       @variable(modelT, LB[i] <= y[i=1:n] <= UB[i])
       @constraint(modelT, Aeq * y .== beq)
       @constraint(modelT, A * y .<= b)
       @objective(modelT, Min, gradient(x_k,Instance)' * y)
       optimize!(modelT)

       write(file, "I am sloving an LP problem over feasible region to get the Toward direction now:\n")
       write(file, "Describing a summary of the model: \n")
       write(file, "Termination Status: $(termination_status(modelT)) \n")
       write(file, "Primal Status: $(primal_status(modelT)) \n")
       write(file, "Message from the solver: $(raw_status(modelT) )\n")
       write(file, "Objective Value: $(objective_value(modelT) )\n")
       write(file, "\n")

        z_k= value.(y)                         #Get the Toward direction at x_k
           
       d_Tk=z_k-x_k


        mrow_A=size(A,1)                           #number of inequality in constraints
        modelA = Model(GLPK.Optimizer)
        @variable(modelA, y_A[1:n])

        for i in 1:n
           
            if abs(x_k[i]- LB[i]) <= 1e-8 || abs(x_k[i]- UB[i]) <= 1e-8     #Find which constraint is active
               @constraint(modelA, y_A[i] == x_k[i])                        #for active upper bound or lower bound
           else
               @constraint(modelA, LB[i] <= y_A[i] <= UB[i])
           end
       end

       
    
       for i in 1:mrow_A                                  #@constraint(model, A * y .<= b)
           if abs(A[i,:]'* x_k -b[i]) <=  1e-8              #A[i,:]'* x == b[i]
               @constraint(modelA, A[i,:]'* y_A == b[i])     #inequality (i) is active
           else 
           @constraint(modelA, A[i,:]'* y_A <= b[i])         #inequality (i) is not active
           end
       end


       @constraint(modelA, Aeq * y_A .== beq)              
       @objective(modelA, Min, -gradient(x_k,Instance)' * y_A)
       optimize!(modelA)

       write(file, "I am sloving an LP problem over feasible region to get the Away  direction now:\n")
       write(file, "Describing a summary of the model: \n")
       write(file, "Termination Status: $(termination_status(modelA)) \n")
       write(file, "Primal Status: $(primal_status(modelA)) \n")
       write(file, "Message from the solver: $(raw_status(modelA) )\n")
       write(file, "Objective Value: $(objective_value(modelA) )\n")
       write(file, "\n")

       w_k=value.(y_A)                          #Get the Away direction at x_k
       d_Ak=x_k-w_k

        gap_value=gap(x_k,z_k,Instance)

        write(file, "The gap is $(gap_value) in this iteration")
        write(file, "\n")

        if gap_value < epsil                                                      #Check if the stop critirion is satisfied
               
            global Terminating="Termination condition with respect to epsilon is satisfied"   #Get the algorithm termination status
            global opt_sol=x_k                                           #Get the final solution
            global opt_val=QP(x_k, Instance)                             #Get the objective function value of the final solution
            break                                                        #Quit the while loop
        end

        if gradient(x_k,Instance)'*d_Tk <= gradient(x_k,Instance)'*d_Ak  #The Toward direction makes the LP reduced more
            d_k=d_Tk                                                     #Set the decent direction be the Toward direction
            gamma_max=1.0
            write(file, "Toward Step is selected \n")
        else
            d_k=d_Ak                                                     #Set the decent direction be the Away direction
            gamma_max=AwayStep_GammaMax(x_k, Instance, d_k)
            write(file, "Away Step is selected \n")
        end
        gamma_k=linesearchQP(x_k, Instance,d_k, gamma_max)        #Find the exactly step size
        x_k=x_k+gamma_k*d_k                                #Get the new iterative point
        value_now=QP(x_k, Instance)
   
        if iter==K                                                #Check if the maximum number of iteration is satisfied
            global rep=0                                          #Discountinue the while loop
            global Terminating="The iteration limit is reached"
            global opt_val=QP(x_k, Instance)
            global opt_sol=x_k
        end


        write(file, "In iteration $(iter), the objective function value of the solution gained is $(value_now)", "\n\n\n")

         
       
    end

    write(file, "$(Terminating) with iteration $(iter) and final value $(opt_val)", "\n\n\n")
    
end


end
