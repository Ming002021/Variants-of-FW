###############################################################################
# Classical Frank-Wolfe Algorithm                                               # 
# Starting point is obtained by KKT                                             #
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


K=250                                                     #Iteration limit
epsil_vec=[1e-2,1e-3,1e-4]                                #Possible convergence tolerance values, epsilon
epsilName_vec=["e2","e3","e4"]  
#epsil=epsil_vec[1]                                       #Choose epsilon value 
#epsilName=epsilName_vec[1]
epsil_length=3
instance_Type_vec=["BoxQP","CUTEr","Globallib","RandQP"]   #Name of our four sets of instances
instance_Type_length_vec=[90,6,83,64]                      #Number of instances in each set
instance_Type=instance_Type_vec[3]                         #Choose one set
instance_Type_length=instance_Type_length_vec[3]

for j in 1:epsil_length

    epsil=epsil_vec[j]                                     #Choose epsilon value 
    epsilName=epsilName_vec[j]

    for i in 1: instance_Type_length     

        output1_path="/Users/Mindy/Desktop/NEW/mat/$(instance_Type)"     #The directory of storing all problems, i.e. storing "boxqp", "randqp", "globallib" and "cuter" folders                             
        cd(output1_path) 
        mat_file=readdir()[i]                                            #Select the mat file that will be used

        Instance=read_instance(mat_file)                                 #Reading all problem data from this mat file 

        Q   = Instance["Q"] 
        c   = Instance["c"]
        LB  = Instance["LB"]                #x >= LB, i.e. -x <=-LB
        UB  = Instance["UB"]                #x <= UB
        A   = Instance["A"]                 #A*x <=b
        b   = Instance["b"]
        Aeq = Instance["Aeq"]               #Aeq*x =beq
        beq = Instance["beq"]
        T   = Instance["T"]  
        n   =length(LB)                     #The size of x, i.e, the number of variabels

        Aieq= vcat(A, Matrix{Float64}(I, n, n), Matrix{Float64}(-I, n, n))        #Combine all inequality constraints together
        bieq=vcat(b, UB, -1*LB )

        ninif_bieq_index=findall(x-> x >-Inf &&  x < Inf,bieq)                    #Find indices of all elements in bieq which are not infinity

        ninif_Aieq=Aieq[ninif_bieq_index,:]                                       #So, now all inequality constraints are combined.       
        ninif_bieq=bieq[ninif_bieq_index,:]                                       #new inequality constraints  Aieq*x <=bieq

        output2_path="/Users/Mindy/Desktop/NEW/Text/CFW_KKT/"                     #Go to the directory used to store output text files                          
        cd(output2_path)

        open("$(mat_file)_$(epsilName).txt", "w") do file  

            model = Model(GLPK.Optimizer)                                         #Using GLPK Slover to slove LP

            @variables(model, begin
            x_free[i=1:n]                   #variabe x_1,...,x_n
            v_free[i=1:size(Aeq,1)]         #Lagrangian multiplier v for constraint Aeq*x =beq
            w[i=1:size(Aieq,1)] >=0         #Lagrangian multiplier u for constraint Aieq*x <=bieq
                                            # w >=0, for Dual feasibility in KKT conditions
            end
            )
        
            @constraints(model, begin

            Q*x_free+c+Aieq'*w-Aeq'*v_free .==0      #Stationarity Conditions in KKT conditions
            Aeq * x_free .== beq                     #Primal feasibility in KKT conditions
            ninif_Aieq *x_free .<=ninif_bieq         #Primal feasibility in KKT conditions
       
            end
            )
            @objective(model, Min, 0)
            optimize!(model)

            write(file,"Using KKT method to get a starting point: \n")
            write(file, "Describing a summary of the model: \n")
            write(file, "Termination Status: $(termination_status(model)) \n")
            write(file, "Primal Status: $(primal_status(model)) \n")
            write(file, "Message from the solver: $(raw_status(model) )\n")
            write(file, "Objective Value of this KKT conditions model: $(objective_value(model) )\n")

            x_1= value.(x_free)                                    #Get the starting point  
            global x_k=x_1                                         #Plug the initial point
            global iter=0                                          #Initialize the iteration number to be 0
            global rep=1                                           #Binary variabe to control if the while loop should be discountinued
            global opt_val=Inf                                     #Initialize the final objective function value to be 0
            global opt_sol=[]                                      #Initialize the final solution to be empty
            global Terminating="" 
            start_value= QP(x_1, Instance)                         #The value of the objective function at the starting point
            write(file, "The value of the objective function of the starting solution is $(start_value) \n")
            write(file, "\n")
   
            write(file,"The  Classical Frank-Wolfe Algorithm with KKT is Starting:\n") 
            write(file, "\n")
             
            while rep==1

                iter=iter+1                          #Remember the first iteration number is 1 in this case 
                                                     #Get the number of iterations processed 
                write(file, "This is the iteration $(iter): \n")
                write(file, "I am solving an LP problem over feasible region to get the Toward direction now:\n")
                
                modelT = Model(GLPK.Optimizer)       #Sloving an LP problem with zero objective function over the feasible region to get the toward direction
                @variable(modelT, LB[i] <= y[i=1:n] <= UB[i])
                @constraint(modelT, Aeq * y .== beq)
                @constraint(modelT, A * y .<= b)
                @objective(modelT, Min, gradient(x_k,Instance)' * y)
                optimize!(modelT)

                
                write(file, "Describing a summary of the model: \n")
                write(file, "Termination Status: $(termination_status(modelT)) \n")
                write(file, "Primal Status: $(primal_status(modelT)) \n")
                write(file, "Message from the solver: $(raw_status(modelT) )\n")
                #write(file, "Objective Value of this LP model is : $(objective_value(modelT) )\n")
                write(file, "\n")

                z_k= value.(y)                         #Get the Toward atom
           
                d_k=z_k-x_k                            #Get the Toward direction at x_k

                gap_value=gap(x_k,z_k,Instance)        #Compute the FW gap at this iteration

                write(file, "The gap is $(gap_value) in this iteration")
                write(file, "\n")

                if gap_value < epsil                                                           #Check if the stop critirion is satisfied
               
                    Terminating="Termination condition with respect to epsilon is satisfied"   #Get the algorithm termination status
                    opt_sol=x_k                                                                #Get the final solution
                    opt_val=QP(x_k, Instance)                                                  #Get the objective function value of the final solution
                    break                                                                      #Quit the while loop
                end
           
                gamma_max=1.0                                                                 #The maximum step-size is 1.0
                gamma_k=linesearchQP(x_k, Instance,d_k, gamma_max)                            #Find the step-size by exact line search

                write(file, "Step-size gained is $(gamma_k)\n")
                write(file, "\n")

                x_k=x_k+gamma_k*d_k                                                          #Get the new iterative point
                value_now=QP(x_k, Instance)                                                  #Compute the value of objective function at this new iterative point

                write(file, "In iteration $(iter), the objective function value of the solution gained is $(value_now)", "\n\n")
   
                if iter==K                                                                   #Check if the maximum number of iteration is satisfied
                    rep=0                                                                    #Discountinue the while loop
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

