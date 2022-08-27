include("./Basic_Functions.jl")
using .MyBasic
include("./Utility_Fun.jl")
using .MyLP_module
using .Myutility_read
using .Myutility_AwayStep_Max   
using .Myutility_LineSearch
using GLPK
using JuMP
using LinearAlgebra
using BenchmarkTools



function PFWA(x_1,K,epsil,A,Aeq,b,beq,LB,UB,Q,c,T,n)


    global x_k=x_1                                         #Plug the initial point
    global iter=0                                          #Initialize the iteration number to be 0
    global rep=1                                           #Binary variabe to control if the while loop should be discountinued
    global opt_val=Inf                                     #Initialize the final objective function value to be 0
    global opt_sol=[]                                      #Initialize the final solution to be empty
    global Terminating="" 
    global D_Weight=Dict(x_1 => 1.0)

     
    while rep==1

    

   #Remember the first iteration is 1
        iter=iter+1    
                                             #Get the number of iterations done so far
    #println("This is the iteration $(iter): \n")
   
        modelT = Model(GLPK.Optimizer)
        @variable(modelT, LB[i] <= y[i=1:n] <= UB[i])
        @constraint(modelT, Aeq * y .== beq)
        @constraint(modelT, A * y .<= b)
        @objective(modelT, Min, (Q*x_k+c)' * y)
        optimize!(modelT)

        z_k= value.(y)                         #Get the Toward direction at x_k
   
        d_Tk=z_k-x_k

        D=collect(keys(D_Weight))

        w_k=solveLP_Away_Atoms(x_k, D, Q,c)                 #Get the Away direction at x_k
    #println("w_k is ", w_k, "\n")
    #println("w_k is in D_Weight $(haskey(D_Weight, w_k)) \n ")
    #the weight of w_k in D
        wk_weight=D_Weight[w_k]
    #println("The weight of w_k in D is $(wk_weight)) \n")
        d_Ak=x_k-w_k

        gap_value=(-(Q*x_k+c))'*d_Tk


        if gap_value < epsil                                                      #Check if the stop critirion is satisfied
       
            Terminating="Termination condition with respect to epsilon is satisfied"   #Get the algorithm termination status
            opt_sol=x_k                                           #Get the final solution
            opt_val=c' * x_k +0.5*(x_k'*Q *x_k)+T[1,1]                            #Get the objective function value of the final solution
            break                                                        #Quit the while loop
        end

        d_k=d_Ak+d_Tk
                                           #Set the decent direction be combination of the Away direction and Toward direction
   
        gamma_max=wk_weight
        gamma_k=linesearchQP(x_k, Q,c, T, d_k, gamma_max)        #Find the exactly step size


        x_k=x_k+gamma_k*d_k                                #Get the new iterative point
        value_now=c' * x_k +0.5*(x_k'*Q *x_k)+T[1,1]

         

        if iter==K                                                #Check if the maximum number of iteration is satisfied
            rep=0                                          #Discountinue the while loop
            Terminating="The iteration limit is reached"
            opt_val=value_now
            opt_sol=x_k
        end

    #update the weight
    

        if gamma_k != 0

            D_Weight[w_k]=D_Weight[w_k]-gamma_k
         
        #println("After updating, the weight of w_k is $(D_Weight[w_k]) \n")
        

            if haskey(D_Weight, z_k) == true
            

                D_Weight[z_k]=D_Weight[z_k]+gamma_k
            else
                D_Weight[z_k]=gamma_k
            end
        #println("After updating, the weight of z_k is $(D_Weight[z_k]) \n")

        end

    
        for (key,value) in D_Weight
            if value <= 1e-8
                delete!(D_Weight,key)
            end
         
        end

         
    end

     

     
end


K=250
epsil_vec=[1e-2,1e-3,1e-4]
epsilName_vec=["e2","e3","e4"]  
instance_Type_vec=["BoxQP","CUTEr","Globallib","RandQP"]
instance_Type_length_vec=[90,6,83,64]
instance_Type=instance_Type_vec[3]
instance_Type_length=instance_Type_length_vec[3]

for j in 3:3

    epsil=epsil_vec[j]
    epsilName=epsilName_vec[j]

    for i in 2:8

        output1_path="/Users/Mindy/Desktop/NEW_RT/mat/$(instance_Type)"                                 
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

        model = Model(GLPK.Optimizer)            #Using GLPK Slover to slove LP
        @variable(model, LB[i] <= x[i=1:n] <= UB[i])
        @constraint(model, A * x .<= b)
        @constraint(model, Aeq * x .== beq)   
        @objective(model, Min, 0)
        optimize!(model)
        
        x_1= value.(x)   
        
        b = @benchmark PFWA($x_1,$K,$epsil,$A,$Aeq,$b,$beq,$LB,$UB,$Q,$c,$T,$n) evals=10 samples=100 seconds = 10000;  
        min = minimum(b)
        runtimes=min.time/1e9
        
        output2_path="/Users/Mindy/Desktop/NEW_RT/Text/PFWA_KKT/$(instance_Type)"                                
        cd(output2_path)

        open("$(mat_file)_$(epsilName).txt", "w") do file  
            write(file, "The running time is $(runtimes)")
        end
        println("$(j) and $(i)\n")
    
    end
end