
module MyFW


include("./Basic_Functions.jl")
using .MyBasic
include("./Utility_Fun.jl")
using .MyLP_module
using .Myutility_AwayStep_Max   
using .Myutility_LineSearch
using GLPK
using JuMP
using LinearAlgebra
 



export CFW            #Classical FW
export ASFW           #Away-steps FW
export ASFWA          #Away-steps FW in atomic version
export PFW            #Pairwise FW
export PFWA           #Pairwise FW in atomic version
 


function CFW(x_1,K,epsil,A,Aeq,b,beq,LB,UB,Q,c,T,n)

 
    global x_k=x_1                                         #Plug the initial point
    global iter=0                                          #Initialize the iteration number to be 0
    global rep=1                                           #Binary variabe to control if the while loop should be discountinued
    global opt_val=Inf                                     #Initialize the final objective function value to be 0
    global opt_sol=[]                                      #Initialize the final solution to be empty
    global Terminating="" 


    while rep==1

        iter=iter+1                          #Remember the first iteration number is 1 in this case 
                                             #Get the number of iterations processed 
        
        modelT = Model(GLPK.Optimizer)       #Sloving an LP problem with zero objective function over the feasible region to get the toward direction
        @variable(modelT, LB[i] <= y[i=1:n] <= UB[i])
        @constraint(modelT, Aeq * y .== beq)
        @constraint(modelT, A * y .<= b)
        @objective(modelT, Min, (Q*x_k+c)' * y)
        optimize!(modelT)


        z_k= value.(y)                         #Get the Toward atom
   
        d_k=z_k-x_k                            #Get the Toward direction at x_k

        gap_value=(-(Q*x_k+c))'*d_k            #Compute the FW gap at this iteration

         
        if gap_value < epsil                                                           #Check if the stop critirion is satisfied
       
            Terminating="Termination condition with respect to epsilon is satisfied"   #Get the algorithm termination status
            opt_sol=x_k                                                                #Get the final solution
            opt_val=c' * x_k +0.5*(x_k'*Q *x_k)+T[1,1]                                 #Get the objective function value of the final solution
            break                                                                      #Quit the while loop
        end
   
        gamma_max=1.0                                                                 #The maximum step-size is 1.0
        gamma_k=linesearchQP(x_k, Q,c, T, d_k, gamma_max)                             #Find the step-size by exact line search


        x_k=x_k+gamma_k*d_k                                                           #Get the new iterative point
        value_now=c' * x_k +0.5*(x_k'*Q *x_k)+T[1,1]                                  #Compute the value of objective function at this new iterative point

        if iter==K                                                                    #Check if the maximum number of iteration is satisfied
            rep=0                                                                     #Discountinue the while loop
            Terminating="The iteration limit is reached"
            opt_val=value_now
            opt_sol=x_k
        end


    end

    return opt_val

end



function ASFW(x_1,K,epsil,A,Aeq,b,beq,LB,UB,Q,c,T,n)

    global x_k=x_1                                         #Plug the initial point
    global iter=0                                          #Initialize the iteration number to be 0
    global rep=1                                           #Binary variabe to control if the while loop should be discountinued
    global opt_val=Inf                                     #Initialize the final objective function value to be 0
    global opt_sol=[]                                      #Initialize the final solution to be empty
    global Terminating="" 
     
    while rep==1

        iter=iter+1                          #Remember the first iteration number is 1 in this case 
                                             #Get the number of iterations processed 
        
        modelT = Model(GLPK.Optimizer)       #Sloving an LP problem with zero objective function over the feasible region to get the toward direction
        @variable(modelT, LB[i] <= y[i=1:n] <= UB[i])
        @constraint(modelT, Aeq * y .== beq)
        @constraint(modelT, A * y .<= b)
        @objective(modelT, Min, (Q*x_k+c)' * y)
        optimize!(modelT)

        z_k= value.(y)                         #Get the Toward atom
   
        d_Tk=z_k-x_k                           #Get the Toward direction at x_k

        mrow_A=size(A,1)                       #Number of inequality in constraints
        modelA = Model(GLPK.Optimizer)         #Sloving an LP problem with zero objective function over the feasible region to get the away direction
        @variable(modelA, y_A[1:n])

        for i in 1:n
   
            if abs(x_k[i]- LB[i]) <= 1e-8 || abs(x_k[i]- UB[i]) <= 1e-8     #For inequality constraints LB <= x <=UB
                @constraint(modelA, y_A[i] == x_k[i])                       #Find which constraint is active
            else
                @constraint(modelA, LB[i] <= y_A[i] <= UB[i])
            end
        end



        for i in 1:mrow_A                                    #For inequality constraints  A*x <=b, find which constraint is active
            if abs(A[i,:]'* x_k -b[i]) <=  1e-8              #if A[i,:]'* x == b[i],inequality (i) is active
                @constraint(modelA, A[i,:]'* y_A == b[i])    #inequality (i) is active
            else 
                @constraint(modelA, A[i,:]'* y_A <= b[i])    #inequality (i) is not active
            end
        end


        @constraint(modelA, Aeq * y_A .== beq)               #equality constraints  Aeq*x =beq
        @objective(modelA, Min, (-(Q*x_k+c))' * y_A)
        optimize!(modelA)


        w_k=value.(y_A)                          #Get the Away atom
        d_Ak=x_k-w_k                             #Get the Away direction at x_k

        gap_value=(-(Q*x_k+c))'*d_Tk             #Compute the FW gap at this iteration

        
        if gap_value < epsil                                                           #Check if the stop critirion is satisfied
       
            Terminating="Termination condition with respect to epsilon is satisfied"   #Get the algorithm termination status
            opt_sol=x_k                                                                #Get the final solution
            opt_val=c' * x_k +0.5*(x_k'*Q *x_k)+T[1,1]                                 #Get the objective function value of the final solution
            break                                                                      #Quit the while loop
        end



        if (Q*x_k+c)'*d_Tk <= (Q*x_k+c)'*d_Ak                           #The Toward direction makes the LP reduced more
            d_k=d_Tk                                                     #Set the decent direction be the Toward direction
            gamma_max=1.0                                                #The maximum step-size is 1.0
             
        else
            d_k=d_Ak                                                     #Set the decent search direction be the Away direction
            gamma_max=AwayStep_GammaMax(x_k, UB,LB,A,b, d_k)              #Find the maximum feasible step-size  
             
        end
                                            
   
     
        gamma_k=linesearchQP(x_k, Q,c, T, d_k, gamma_max)                #Find the step-size by exact line search

        x_k=x_k+gamma_k*d_k                                              #Get the new iterative point
        value_now=c' * x_k +0.5*(x_k'*Q *x_k)+T[1,1]                                  #Compute the value of objective function at this new iterative point


        if iter==K                                                                   #Check if the maximum number of iteration is satisfied
            rep=0                                                                    #Discountinue the while loop
            Terminating="The iteration limit is reached"
            opt_val=value_now
            opt_sol=x_k
        end
    end

    return opt_val

     
end



function PFW(x_1,K,epsil,A,Aeq,b,beq,LB,UB,Q,c,T,n)
    global x_k=x_1                                         #Plug the initial point
    global iter=0                                          #Initialize the iteration number to be 0
    global rep=1                                           #Binary variabe to control if the while loop should be discountinued
    global opt_val=Inf                                     #Initialize the final objective function value to be 0
    global opt_sol=[]                                      #Initialize the final solution to be empty
    global Terminating="" 
     
    while rep==1

        iter=iter+1                          #Remember the first iteration number is 1 in this case 
                                             #Get the number of iterations processed 
        
        modelT = Model(GLPK.Optimizer)       #Sloving an LP problem with zero objective function over the feasible region to get the toward direction
        @variable(modelT, LB[i] <= y[i=1:n] <= UB[i])
        @constraint(modelT, Aeq * y .== beq)
        @constraint(modelT, A * y .<= b)
        @objective(modelT, Min, (Q*x_k+c)' * y)
        optimize!(modelT)


        z_k= value.(y)                         #Get the Toward atom
   
        d_Tk=z_k-x_k                            #Get the Toward direction at x_k

        mrow_A=size(A,1)                       #Number of inequality in constraints
        modelA = Model(GLPK.Optimizer)         #Sloving an LP problem with zero objective function over the feasible region to get the away direction
        @variable(modelA, y_A[1:n])

        for i in 1:n
   
            if abs(x_k[i]- LB[i]) <= 1e-8 || abs(x_k[i]- UB[i]) <= 1e-8     #For inequality constraints LB <= x <=UB
                @constraint(modelA, y_A[i] == x_k[i])                       #Find which constraint is active
            else
                @constraint(modelA, LB[i] <= y_A[i] <= UB[i])
            end
        end



        for i in 1:mrow_A                                    #For inequality constraints  A*x <=b, find which constraint is active
            if abs(A[i,:]'* x_k -b[i]) <=  1e-8              #if A[i,:]'* x == b[i],inequality (i) is active
                @constraint(modelA, A[i,:]'* y_A == b[i])    #inequality (i) is active
            else 
                @constraint(modelA, A[i,:]'* y_A <= b[i])    #inequality (i) is not active
            end
        end


        @constraint(modelA, Aeq * y_A .== beq)               #equality constraints  Aeq*x =beq
        @objective(modelA, Min, (-(Q*x_k+c))' * y_A)
        optimize!(modelA)


        w_k=value.(y_A)                          #Get the Away atom
        d_Ak=x_k-w_k                             #Get the Away direction at x_k

        gap_value=(-(Q*x_k+c))'*d_Tk             #Compute the FW gap at this iteration

         
        if gap_value < epsil                                                           #Check if the stop critirion is satisfied
       
            Terminating="Termination condition with respect to epsilon is satisfied"   #Get the algorithm termination status
            opt_sol=x_k                                                                #Get the final solution
            opt_val=c' * x_k +0.5*(x_k'*Q *x_k)+T[1,1]                                                  #Get the objective function value of the final solution
            break                                                                      #Quit the while loop
        end

        d_k=d_Ak+d_Tk                                        #Set the decent direction be combination of the Away direction and Toward direction
                                           
   
        gamma_max=AwayStep_GammaMax(x_k, UB,LB,A,b, d_k)      #Find the maximum feasible step-size  
        gamma_k=linesearchQP(x_k, Q,c, T, d_k, gamma_max)     #Find the step-size by exact line search

         
        x_k=x_k+gamma_k*d_k                                              #Get the new iterative point
        value_now=c' * x_k +0.5*(x_k'*Q *x_k)+T[1,1]                     #Compute the value of objective function at this new iterative point

         

        if iter==K                                                                   #Check if the maximum number of iteration is satisfied
            rep=0                                                                    #Discountinue the while loop
            Terminating="The iteration limit is reached"
            opt_val=value_now
            opt_sol=x_k
        end
    end

        return opt_val

end

    function ASFWA(x_1,K,epsil,A,Aeq,b,beq,LB,UB,Q,c,T,n)

        global x_k=x_1                                         #Plug the initial point
        global iter=0                                          #Initialize the iteration number to be 0
        global rep=1                                           #Binary variabe to control if the while loop should be discountinued
        global opt_val=Inf                                     #Initialize the final objective function value to be 0
        global opt_sol=[]                                      #Initialize the final solution to be empty
        global Terminating="" 
        global D_Weight=Dict(x_1 => 1.0)                       #Using a dictionary to keep track of active set and active stoms
                                                               #The keys are active atoms which have non-zero weights
        while rep==1

            iter=iter+1                          #Remember the first iteration number is 1 in this case 
                                                 #Get the number of iterations processed 
            
            modelT = Model(GLPK.Optimizer)       #Sloving an LP problem with zero objective function over the feasible region to get the toward direction
            @variable(modelT, LB[i] <= y[i=1:n] <= UB[i])
            @constraint(modelT, Aeq * y .== beq)
            @constraint(modelT, A * y .<= b)
            @objective(modelT, Min, (Q*x_k+c)' * y)
            optimize!(modelT)


            z_k= value.(y)                         #Get the Toward atom
       
            d_Tk=z_k-x_k                           #Get the Toward direction at x_k

            D=collect(keys(D_Weight))                                  #D is the active set at this iteration
            #println("D is ",D,"\n")
            #println("D_Weight is ",D_Weight,"\n")

            w_k=solveLP_Away_Atoms(x_k, D, Q,c)                       #Get the away atom              
            #println("w_k is ", w_k, "\n")
            #println("w_k is in D_Weight $(haskey(D_Weight, w_k)) \n ")
            #the weight of w_k in D
            wk_weight=D_Weight[w_k]                                    #Get the weight of this away tome
            #println("The weight of w_k in D is $(wk_weight)) \n")
            d_Ak=x_k-w_k                                               #Get the Away direction at x_k

            gap_value=(-(Q*x_k+c))'*d_Tk         #Compute the FW gap at this iteration

             

            if gap_value < epsil                                                            #Check if the stop critirion is satisfied
           
                Terminating="Termination condition with respect to epsilon is satisfied"    #Get the algorithm termination status
                opt_sol=x_k                                                                 #Get the final solution
                opt_val=c' * x_k +0.5*(x_k'*Q *x_k)+T[1,1]                                                     #Get the objective function value of the final solution
                break                                                                       #Quit the while loop
            end


            if (Q*x_k+c)'*d_Tk <= (Q*x_k+c)'*d_Ak                            #The Toward direction makes the LP reduced more
                d_k=d_Tk                                                     #Set the decent direction be the Toward direction
                gamma_max=1.0                                                #The maximum step-size is 1.0
                gamma_k=linesearchQP(x_k, Q,c, T, d_k, gamma_max)            #Find the step-size by exact line search
                x_k=x_k+gamma_k*d_k                                          #Get the new iterative point
                value_now=c' * x_k +0.5*(x_k'*Q *x_k)+T[1,1]                              #Compute the value of objective function at this new iterative point
                 
            
                if haskey(D_Weight, z_k) == true                             #If z_k is already in D
                    
                    for (key,value) in D_Weight

                        if key==z_k

                            D_Weight[key]=value*(1-gamma_k)+gamma_k          #Update weight of z_k in D 
                        else
                            D_Weight[key]=value*(1-gamma_k)                  #Update weights of all other atoms in D 
                        end
                         
                    end
                else 

                    for (key,value) in D_Weight                             #if z_k is not already  in D

                        D_Weight[key]=value*(1-gamma_k)                     #Update weights of all atoms in D  
                    end
                    D_Weight[z_k]=gamma_k                                   #Add z_k into D, update the active set D and add weight of z_k
                end

            else

                d_k=d_Ak                                                    #Set the decent direction be the Away direction
                gamma_max=wk_weight/(1.0-wk_weight)                         #Find the maximum feasible step-size 
                 
                gamma_k=linesearchQP(x_k, Q,c, T, d_k, gamma_max)           #Find the step-size by exact line search
                 
                x_k=x_k+gamma_k*d_k                                         #Get the new iterative point
                value_now=c' * x_k +0.5*(x_k'*Q *x_k)+T[1,1]                #Compute the value of objective function at this new iterative point
                  
            
                for (key,value) in D_Weight                                 #Note that w_k must be in D

                    if key==w_k                                             #Update weights of all atoms in D  

                        D_Weight[key]=value*(1+gamma_k)-gamma_k
                    else
                        D_Weight[key]=value*(1+gamma_k)
                    end
                     
                end
            
            end

            if iter==K                                                         #Check if the maximum number of iteration is satisfied
                rep=0                                                          #Discountinue the while loop
                Terminating="The iteration limit is reached"
                opt_val=value_now
                opt_sol=x_k
            end

         
            for (key,value) in D_Weight
                if value <= 1e-8                   #Get all atoms which have non-zero weight
                    delete!(D_Weight,key)          #Update D_Weight
                end
            end
        end


        return opt_val

    end



        function PFWA(x_1,K,epsil,A,Aeq,b,beq,LB,UB,Q,c,T,n)

            global x_k=x_1                                         #Plug the initial point
            global iter=0                                          #Initialize the iteration number to be 0
            global rep=1                                           #Binary variabe to control if the while loop should be discountinued
            global opt_val=Inf                                     #Initialize the final objective function value to be 0
            global opt_sol=[]                                      #Initialize the final solution to be empty
            global Terminating="" 
            global D_Weight=Dict(x_1 => 1.0)
        
             
            while rep==1

                iter=iter+1                          #Remember the first iteration number is 1 in this case 
                                                     #Get the number of iterations processed 
                
                modelT = Model(GLPK.Optimizer)       #Sloving an LP problem with zero objective function over the feasible region to get the toward direction
                @variable(modelT, LB[i] <= y[i=1:n] <= UB[i])
                @constraint(modelT, Aeq * y .== beq)
                @constraint(modelT, A * y .<= b)
                @objective(modelT, Min, (Q*x_k+c)' * y)
                optimize!(modelT)

                 
                z_k= value.(y)                         #Get the Toward atom
           
                d_Tk=z_k-x_k                           #Get the Toward direction at x_k

                D=collect(keys(D_Weight))                                 #D is the active set at this iteration
                #println("D is ",D,"\n")
                #println("D_Weight is ",D_Weight,"\n")

                w_k=solveLP_Away_Atoms(x_k, D, Q,c)                      #Get the away atom              
                #println("w_k is ", w_k, "\n")
                #println("w_k is in D_Weight $(haskey(D_Weight, w_k)) \n ")
                #the weight of w_k in D
                wk_weight=D_Weight[w_k]                                    #Get the weight of this away tome
                #println("The weight of w_k in D is $(wk_weight)) \n")
                d_Ak=x_k-w_k                                               #Get the Away direction at x_k

                gap_value=(-(Q*x_k+c))'*d_Tk          #Compute the FW gap at this iteration

                

                if gap_value < epsil                                                            #Check if the stop critirion is satisfied
               
                    Terminating="Termination condition with respect to epsilon is satisfied"    #Get the algorithm termination status
                    opt_sol=x_k                                                                 #Get the final solution
                    opt_val=c' * x_k +0.5*(x_k'*Q *x_k)+T[1,1]                                  #Get the objective function value of the final solution
                    break                                                                       #Quit the while loop
                end

                d_k=d_Ak+d_Tk                                        #Set the decent direction be combination of the Away direction and Toward direction
                                                   
           
                gamma_max=wk_weight                                  #The maximum step-size is the weight of w_k
                gamma_k=linesearchQP(x_k, Q,c, T, d_k, gamma_max) #Find the step-size by exact line search

                 

                x_k=x_k+gamma_k*d_k                                #Get the new iterative point
                value_now=c' * x_k +0.5*(x_k'*Q *x_k)+T[1,1]       #Compute the value of objective function at this new iterative point

                 
                #The following is to update theactive set and weights of all atoms in active set

                if gamma_k != 0

                    D_Weight[w_k]=D_Weight[w_k]-gamma_k            #Update the weight of w_K
                 
                    #println("After updating, the weight of w_k is $(D_Weight[w_k]) \n")
                

                    if haskey(D_Weight, z_k) == true               #If z_k is already in D
                    
                        D_Weight[z_k]=D_Weight[z_k]+gamma_k        #Update weight of z_k in D 
                    else
                        D_Weight[z_k]=gamma_k
                    end
                   #println("After updating, the weight of z_k is $(D_Weight[z_k]) \n")

                end

                if iter==K                                                         #Check if the maximum number of iteration is satisfied
                    rep=0                                                          #Discountinue the while loop
                    Terminating="The iteration limit is reached"
                    opt_val=value_now
                    opt_sol=x_k
                end

            
                for (key,value) in D_Weight
                    if value <= 1e-8                   #Get all atoms which have non-zero weight
                        delete!(D_Weight,key)          #Update D_Weight
                    end
                end
            end


            return opt_val
        end


end
