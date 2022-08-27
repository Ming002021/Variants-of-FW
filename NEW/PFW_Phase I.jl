###############################################################################
# Pairwise Frank-Wolfe Algorithm                                                # 
# Starting point is obtained by Phase I                                         #
# The results are output to text files,                                         #
# including the final results and everything during this iterative procedyre    #
# The results of each iteration is output to a text file                        #
# For each epsilon and each instance, there is a textfile                       #
#################################################################################





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
epsil=epsil_vec[3]
epsilName=epsilName_vec[3]
instance_Type_vec=["BoxQP","CUTEr","Globallib","RandQP"]
instance_Type_length_vec=[90,6,83,64]
instance_Type=instance_Type_vec[3]
instance_Type_length=instance_Type_length_vec[3]

for j in 1:3

    epsil=epsil_vec[j]
    epsilName=epsilName_vec[j]

    for i in 71:83 #instance_Type_length

        output1_path="/Users/Mindy/Desktop/NEW/mat/$(instance_Type)"                                 
        cd(output1_path) 
        mat_file=readdir()[i]  

        Instance=read_instance(mat_file)



        Q   = Instance["Q"] 
        c   = Instance["c"]
        LB  = Instance["LB"]                #x >= LB, i.e. -x <=-LB
        UB  = Instance["UB"]                # x <= UB
        A   = Instance["A"]                 #A*x <=b
        b   = Instance["b"]
        Aeq = Instance["Aeq"]               #Aeq*x <=beq
        beq = Instance["beq"]
        T   = Instance["T"]  
        n   =length(LB)                          #The size of x, i.e, the number of variabels


        output2_path="/Users/Mindy/Desktop/NEW/Text/PFW_Phase I/$(instance_Type)"                                
        cd(output2_path)

        open("$(mat_file)_$(epsilName).txt", "w") do file  

            model = Model(GLPK.Optimizer)            #Using GLPK Slover to slove LP
            @variable(model, LB[i] <= x[i=1:n] <= UB[i])
            @constraint(model, A * x .<= b)
            @constraint(model, Aeq * x .== beq)   
            @objective(model, Min, 0)
            optimize!(model)

        
            write(file,"Using Phase I method to get a starting point: \n")
            write(file, "Describing a summary of the model: \n")
            write(file, "Termination Status: $(termination_status(model)) \n")
            write(file, "Primal Status: $(primal_status(model)) \n")
            write(file, "Message from the solver: $(raw_status(model) )\n")
            write(file, "Objective Value: $(objective_value(model) )\n")
            write(file, "\n")

            x_1= value.(x)  
            global x_k=x_1                                         #Plug the initial point
            global iter=0                                          #Initialize the iteration number to be 0
            global rep=1                                           #Binary variabe to control if the while loop should be discountinued
            global opt_val=Inf                                     #Initialize the final objective function value to be 0
            global opt_sol=[]                                      #Initialize the final solution to be empty
            global Terminating="" 
            start_value= QP(x_1, Instance)
            write(file, "The value of the objective function of the starting solution is $(start_value) \n")
            write(file, "\n")
   
            write(file,"The  Pairwise Frank-Wolfe Algorithm with Phase I is Starting:\n") 
            write(file, "\n")
             
            while rep==1

           #Remember the first iteration is 1
                iter=iter+1    
                                                     #Get the number of iterations done so far
                write(file, "This is the iteration $(iter): \n")
           
                modelT = Model(GLPK.Optimizer)
                @variable(modelT, LB[i] <= y[i=1:n] <= UB[i])
                @constraint(modelT, Aeq * y .== beq)
                @constraint(modelT, A * y .<= b)
                @objective(modelT, Min, gradient(x_k,Instance)' * y)
                optimize!(modelT)

                write(file, "I am solving an LP problem over feasible region to get the Toward direction now:\n")
                write(file, "Describing a summary of the model: \n")
                write(file, "Termination Status: $(termination_status(modelT)) \n")
                write(file, "Primal Status: $(primal_status(modelT)) \n")
                write(file, "Message from the solver: $(raw_status(modelT) )\n")
                #write(file, "Objective Value of this LP model is : $(objective_value(modelT) )\n")
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

                write(file, "I am solving an LP problem over feasible region to get the Away  direction now:\n")
                write(file, "Describing a summary of the model: \n")
                write(file, "Termination Status: $(termination_status(modelA)) \n")
                write(file, "Primal Status: $(primal_status(modelA)) \n")
                write(file, "Message from the solver: $(raw_status(modelA) )\n")
                #write(file, "Objective Value: $(objective_value(modelA) )\n")
                write(file, "\n")

                w_k=value.(y_A)                          #Get the Away direction at x_k
                d_Ak=x_k-w_k

                gap_value=gap(x_k,z_k,Instance)

                write(file, "The gap is $(gap_value) in this iteration")
                write(file, "\n")

                if gap_value < epsil                                                      #Check if the stop critirion is satisfied
               
                    Terminating="Termination condition with respect to epsilon is satisfied"   #Get the algorithm termination status
                    opt_sol=x_k                                           #Get the final solution
                    opt_val=QP(x_k, Instance)                             #Get the objective function value of the final solution
                    break                                                        #Quit the while loop
                end

                d_k=d_Ak+d_Tk
                                                   #Set the decent direction be combination of the Away direction and Toward direction
           
                gamma_max=AwayStep_GammaMax(x_k, Instance, d_k)
                gamma_k=linesearchQP(x_k, Instance,d_k, gamma_max)        #Find the exactly step size

                write(file, "Step-size gained is $(gamma_k)\n")
                write(file, "\n")

                x_k=x_k+gamma_k*d_k                                #Get the new iterative point
                value_now=QP(x_k, Instance)

                write(file, "In iteration $(iter), the objective function value of the solution gained is $(value_now)", "\n\n")
   
                if iter==K                                                #Check if the maximum number of iteration is satisfied
                    rep=0                                          #Discountinue the while loop
                    Terminating="The iteration limit is reached"
                    opt_val=value_now
                    opt_sol=x_k
                end

                write(file, "\n")
            end

            write(file,"\n")

            write(file, "$(Terminating) with iteration $(iter) and final value $(opt_val)", "\n\n\n")
        end
    end
    
end