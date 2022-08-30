__precompile__()


##############################################
#This script gives the following:            #
# module MyFW                                #
# 	function Classical_FW_QP                 #
# 	function AwayStep_FW_QP                  #   
# 	function Pairwise_FW_QP                  #
#   function FullCorrection_FW_QP (Not used) #
#   function AwayStep_Atoms_FW_QP            #
#   function Pairwise_Atoms_FW_QP            #
##############################################


module MyFW


    include("./Basic_Functions.jl")
    using .MyBasic
    include("./Utility_Fun.jl")
    using .Myutility_LineSearch
    using .Myutility_AwayStep_Max
    include("./Solve_LP.jl")
    using .MyLP_module



    export Classical_FW_QP
    export AwayStep_FW_QP
    export Pairwise_FW_QP
    #export FullCorrection_FW_QP
    export Pairwise_FW_QP_Debug

    export AwayStep_Atoms_FW_QP
    export Pairwise_Atoms_FW_QP

    #export Pairwise_FW_QP_Debug

    function Classical_FW_QP(epsil::Float64,K::Int64,Instance)

        ######################################################################################################
        # Function on the Classical Frank Wolfe algorithm with exactly line search step size.                #
        # Instance is the QP problem                                                                         #
        # epsil is the approximation error                                                                   #
        # K is a reasonable iteration limit                                                                  #                                                                   #
        ######################################################################################################
        x_1= KKT_StartPoint(Instance)                          #Get the starting point using solveLP_StartPoint  #solveLP_StartPoint(Instance)  #StartPoint_Two_PhaseSimplex(Instance)      
        global x_k=x_1                                         #Plug the initial point
        global iter=0                                          #Initialize the iteration number to be 0
        global rep=1                                           #Binary variabe to control if the while loop should be discountinued
        global opt_val=Inf                                     #Initialize the final objective function value to be 0
        global opt_sol=[]                                      #Initialize the final solution to be empty
        global Terminating=""  
        
        while rep==1

            iter=iter+1                                 #Get the number of iterations done
                                                        #Remember the first iteration is 1, in this case
            z_k=solveLP_Toward(x_k,Instance)            #Get the Toward direction at x_k
            d_k=z_k-x_k
    
            if gap(x_k,z_k,Instance) < epsil                                                         #Check if the stop critirion is satisfied
                global Terminating="Termination condition with respect to epsilon is satisfied"      #Get the reason that the algorithm terminated
                global opt_sol=x_k                                                                   #Get the final solution
                global opt_val=QP(x_k, Instance)                                                     #Get the objective function value of the final solution
                break                                                                                #Quit the while loop as the stop critirion is satisfied
            end
    
            gamma_max=1.0
            gamma_k=linesearchQP(x_k, Instance,d_k, gamma_max)           #Find the exactly step size
            x_k=x_k+gamma_k*d_k                                          #Get the new iterative point
    
            if iter==K                                                   #Check if the maximum number of iteration is satisfied
                global rep=0                                             #Discountinue the while loop
                global Terminating="The iteration limit is reached"
                global opt_sol=x_k
                global opt_val=QP(x_k, Instance)
            end
    
        end
        return Terminating,iter,opt_val
    end




    function AwayStep_FW_QP(epsil::Float64,K::Int64,Instance)

        ######################################################################################################
        # Function on the Away Steps Frank Wolfe algorithm with exactly line search step size                #
         # Instance is the QP problem                                                                        #
        # epsil is the approximation error                                                                   #
        # K is a reasonable iteration limit                                                                  #                                                                   #
        ######################################################################################################



        x_1=  KKT_StartPoint(Instance)#solveLP_StartPoint(Instance) #KKT_StartPoint(Instance) #solveLP_StartPoint(Instance) #KKT_StartPoint(Instance) #StartPoint_Two_PhaseSimplex(Instance)      #solveLP_StartPoint(Instance)  #Get the starting point using solveLP_StartPoint or StartPoint_Two_PhaseSimplex
        global x_k=x_1                                         #Plug the initial point
        global iter=0                                          #Initialize the iteration number to be 0
        global rep=1                                           #Binary variabe to control if the while loop should be discountinued
        global opt_val=Inf                                     #Initialize the final objective function value to be 0
        global opt_sol=[]                                      #Initialize the final solution to be empty
        global Terminating=""  
    
    
        while rep==1
            iter=iter+1                                                #Get the number of iterations done so far
            z_k=solveLP_Toward(x_k,Instance)                           #Get the Toward direction at x_k
            d_Tk=z_k-x_k
            w_k=solveLP_Away(x_k,Instance)                             #Get the Away direction at x_k
            d_Ak=x_k-w_k

            if gap(x_k,z_k,Instance) < epsil                                                      #Check if the stop critirion is satisfied
                global Terminating="Termination condition with respect to epsilon is satisfied"   #Get the algorithm termination status
                global opt_sol=x_k                                           #Get the final solution
                global opt_val=QP(x_k, Instance)                             #Get the objective function value of the final solution
                break                                                        #Quit the while loop
            end

                                                                             #If the stop critirion is not satisfied

            if gradient(x_k,Instance)'*d_Tk <= gradient(x_k,Instance)'*d_Ak  #The Toward direction makes the LP reduced more
                d_k=d_Tk                                                     #Set the decent direction be the Toward direction
                gamma_max=1.0
            else
                d_k=d_Ak                                                     #Set the decent direction be the Away direction
                gamma_max=AwayStep_GammaMax(x_k, Instance, d_k)
            end

            gamma_k=linesearchQP(x_k, Instance, d_k,gamma_max)               #Find the exactly step size
            x_k=x_k+gamma_k*d_k                                              #Get the new iterative point

            if iter==K                                                              #Check if the maximum number of iteration is satisfied
                global rep=0                                                        #Discountinue the while loop
                global Terminating="The iteration limit is reached"
                global opt_val=QP(x_k, Instance)
                global opt_sol=x_k
            end

        end
        return Terminating,iter,opt_val 

    end





    function Pairwise_FW_QP(epsil::Float64,K::Int64,Instance)

        ######################################################################################################
        # Function on the Pairwise Frank Wolfe algorithm with exactly line search step size                  #
        # Instance is the QP problem                                                                         #
        # epsil is the approximation error                                                                   #
        # K is a reasonable iteration limit                                                                  #                                                                   #
        ######################################################################################################



        x_1= KKT_StartPoint(Instance)                          #solveLP_StartPoint(Instance)#KKT_StartPoint(Instance)     
        global x_k=x_1                                         #Plug the initial point
        global iter=0                                          #Initialize the iteration number to be 0
        global rep=1                                           #Binary variabe to control if the while loop should be discountinued
        global opt_val=Inf                                     #Initialize the final objective function value to be 0
        global opt_sol=[]                                      #Initialize the final solution to be empty
        global Terminating=""  
    
        
        while rep==1

            iter=iter+1                                              #Get the number of iterations done so far
            z_k=solveLP_Toward(x_k,Instance)                         #Get the Toward direction at x_k
            d_Tk=z_k-x_k
            w_k=solveLP_Away(x_k,Instance)                            #Get the Away direction at x_k
            d_Ak=x_k-w_k

            if gap(x_k,z_k,Instance) < epsil                                                      #Check if the stop critirion is satisfied
                global Terminating="Termination condition with respect to epsilon is satisfied"   #Get the algorithm termination status
                global opt_sol=x_k                                           #Get the final solution
                global opt_val=QP(x_k, Instance)                             #Get the objective function value of the final solution
                break                                                        #Quit the while loop
            end
    
            
            d_k=d_Tk+d_Ak                                             #Set the decent direction be combination of the Away direction and Toward direction
            gamma_max=AwayStep_GammaMax(x_k, Instance,d_k)
            gamma_k=linesearchQP(x_k, Instance,d_k, gamma_max)        #Find the exactly step size
            x_k=x_k+gamma_k*d_k                                       #Get the new iterative point
    
            if iter==K                                                #Check if the maximum number of iteration is satisfied
                global rep=0                                          #Discountinue the while loop
                global Terminating="The iteration limit is reached"
                global opt_val=QP(x_k, Instance)
                global opt_sol=x_k
            end
    
        end
        return Terminating,iter,opt_val 
    
        
    end






    function AwayStep_Atoms_FW_QP(epsil::Float64,K::Int64,Instance)

        ######################################################################################################
        # Function on the Away Steps Frank Wolfe algorithm with exactly line search step size                #
        # Instance is the QP problem                                                                         #
        # epsil is the approximation error                                                                   #
        # K is a reasonable iteration limit                                                                  # 
        # Get the away direction by minimizing the -gradient*x_k over the active set D  containing the       #
        # previous discovered search vertices in previous iterations                                         #
        ######################################################################################################
    
    
        x_1= KKT_StartPoint(Instance)                          #solveLP_StartPoint(Instance)  
        global x_k=x_1                                         #Plug the initial point
        global iter=0                                          #Initialize the iteration number to be 0
        global rep=1                                           #Binary variabe to control if the while loop should be discountinued
        global opt_val=Inf                                     #Initialize the final objective function value to be 0
        global opt_sol=[]                                      #Initialize the final solution to be empty
        global Terminating="" 
        global D=[x_1]                                         #D is an active set, containing the previous discovered search vertices in previous iterations
                                                               #Actually, x_k is a convex combination of some atoms in D
        global Weight_D=[1.0]                                  #Containing weights of each atoms in D
    
        while rep==1
    
            iter=iter+1                                          #Get the number of iterations done so far
            z_k=solveLP_Toward(x_k,Instance)                     #Get the Toward direction at x_k
            d_Tk=z_k-x_k
            w_k=solveLP_Away_Atoms(x_k,D,Instance)               #Get the Away direction at x_k
            
             

            d_Ak=x_k-w_k    
            
            
    
            if gap(x_k,z_k,Instance) < epsil                                                      #Check if the stop critirion is satisfied
                global Terminating="Termination condition with respect to epsilon is satisfied"   #Get the algorithm termination status
                global opt_sol=x_k                                           #Get the final solution
                global opt_val=QP(x_k, Instance)                             #Get the objective function value of the final solution
                break                                                        #Quit the while loop
            end
    
                                                                            #If the stop critirion is not satisfied
    
            if gradient(x_k,Instance)'*d_Tk <= gradient(x_k,Instance)'*d_Ak #The Toward direction makes the LP reduced more
                 
                
                d_k=d_Tk                                                    #Set the decent direction be the Toward direction
                gamma_max=1.0
                gamma_k=linesearchQP(x_k, Instance, d_k,gamma_max)          #Find the exactly step size
                x_k=x_k+gamma_k*d_k                                         #Get the new iterative point
    
                if z_k in D == true                      #If z_k already in D

                    Index_zk_D=findall(x-> x==z_k,D)     #If z_k already in D, find its position in D

                    Non_Index_zk_D=findall(x-> x !=z_k,D)  
                    Weight_D[Index_zk_D] .= (1-gamma_k) * Weight_D[Index_zk_D] .+gamma_k   #Update weight of z_k in D 
                    if isempty(Non_Index_zk_D) ==false

                        Weight_D[Non_Index_zk_D] .= (1-gamma_k) * Weight_D[Non_Index_zk_D]  #Update weights of all atoms in D 
                    end

                    
                else #if z_k not already  in D
                    
                    push!(D,z_k)                                #Add z_k into D
                    global Weight_D=(1-gamma_k)*Weight_D        #Update the active set D and weights of all atoms in D     
                    push!(Weight_D, gamma_k)                    #Add weight of z_k into Weight_D
    
                end
    
            else

    
                d_k=d_Ak                                                        #Set the decent direction be the Away direction
                gamma_max=wk_weight/(1.0-wk_weight)      ###########################################################################################
                                                         #In away step direction, computing the true maximum feasible step-size                   #
                                                         #would require the ability to know when we cross the boundary of feasible region.        #
                                                         #Setting the maximum step-size to be wk_weight/(1-wk_weight) can avoid this problem      #
                                                         #When the feasible region is a simplex, x_k+gamma_max*d_Ak truly lies on the boundary of #
                                                         #########################################################################################
    
                gamma_k=linesearchQP(x_k, Instance, d_k,gamma_max)               #Find the exactly step size
                x_k=x_k+gamma_k*d_k                                              #Get the new iterative point
                
                #Index_wk_D=findall(x-> x==w_k,D)                                #Update weights of all atoms in D  
                Non_Index_wk_D=findall(x-> x !=w_k,D)
                Weight_D[Index_wk_D] .= (1+gamma_k) * Weight_D[Index_wk_D] .-gamma_k
                
                if isempty(Non_Index_wk_D) ==false

                    Weight_D[Non_Index_wk_D] .= (1+gamma_k) * Weight_D[Non_Index_wk_D]
                end
                
    
            end
    
            Non_zero_Index=findall(x -> x!=0, Weight_D)           #Get all atoms which have non-zero weight
            global D=D[Non_zero_Index]                            #Update D and Weight_D
            global Weight_D=Weight_D[Non_zero_Index]
            
        
            if iter==K                                                              #Check if the maximum number of iteration is satisfied
                global rep=0                                                        #Discountinue the while loop
                global Terminating="The iteration limit is reached "
                global opt_val=QP(x_k, Instance)
                global opt_sol=x_k
            end
    
        end
        return Terminating,iter,opt_val,opt_sol
    
    end




    function  Pairwise_Atoms_FW_QP(epsil::Float64,K::Int64,Instance)

        ######################################################################################################
        # Function on the Pairwise Frank Wolfe algorithm with exactly line search step size                  #
        # Instance is the QP problem                                                                         #
        # epsil is the approximation error                                                                   #
        # K is a reasonable iteration limit                                                                  # 
        # Get the away direction by minimizing the -gradient*x_k over the active set D  containing the       #
        # previous discovered search vertices in previous iterations                                         #
        ######################################################################################################
    
    
        x_1= KKT_StartPoint(Instance)                          #solveLP_StartPoint(Instance)  
        global x_k=x_1                                         #Plug the initial point
        global iter=0                                          #Initialize the iteration number to be 0
        global rep=1                                           #Binary variabe to control if the while loop should be discountinued
        global opt_val=Inf                                     #Initialize the final objective function value to be 0
        global opt_sol=[]                                      #Initialize the final solution to be empty
        global Terminating=""
        global D=[x_1]                                         #D is an active set, containing the previous discovered search vertices in previous iterations
                                                               #Actually, x_k is convex combination of some atoms in D
        global Weight_D=[1.0]                                  #Containing weights of each atoms in D
    
        while rep==1
    
            iter=iter+1                                        #Get the number of iterations done so far
            z_k=solveLP_Toward(x_k,Instance)                   #Get the Toward direction at x_k
            d_Tk=z_k-x_k
            w_k=solveLP_Away_Atoms(x_k,D,Instance)             #Get the Away direction at x_k
            
            if typeof(w_k) ==Nothing
                w_k=x_k
            end
            d_Ak=x_k-w_k  
            
            Index_wk_D=findall(x-> x==w_k,D)                          #Get the index of w_k in D
            wk_weight=Weight_D[Index_wk_D][1]                         #Get the weight if w_k 
            #println(wk_weight)
    
    
            if gap(x_k,z_k,Instance) < epsil                                                #Check if the stop critirion is satisfied
                Terminating="Termination condition with respect to epsilon is satisfied"    #Get the algorithm termination status
                opt_sol=x_k                                                                 #Get the final solution
                opt_val=QP(x_k, Instance)                                                   #Get the objective function value of the final solution
                break                                                                       #Qiut the while loop
            end
    
                                                                            #If the stop critirion is not satisfied
    
            d_k=d_Tk+d_Ak                                                   #Pairwise Frank-Wolfe direction is d_Tk+d_Ak =z_k-w_k
            gamma_max=wk_weight
            gamma_k=linesearchQP(x_k, Instance, d_k,gamma_max)              #Find the exactly step size
            x_k=x_k+gamma_k*d_k                                             #Get the new iterative point
    
            #Update the active set and weights of z_k and w_k
            #All other atoms in D keep unchanged
    
            if gamma_k!=0  #x_k=x_k+gamma_k*d_k=x_k+gamma_k*(z_k-w_k)
    
                Weight_D[Index_wk_D] =Weight_D[Index_wk_D] .-gamma_k        #Update the weight of w_k 
    
                if z_k in D == true                                         #If z_k is already in D
                    
                    Index_zk_D=findall(x-> x==z_k,D)                        #Get the index of z_k in D
                    Weight_D[Index_zk_D] .= Weight_D[Index_zk_D].+gamma_k   #Update the weight of z_k 
                    
                else  
                 #if z_k not already in D
    
                push!(D,z_k)                                                 #Add z_k and its weight into D and Weight_D, respectively
                push!(Weight_D, gamma_k)
                    
                end
            end
                                                             
            #println(Weight_D)

            Non_zero_Index=findall(x -> x!=0, Weight_D)           #Get all atoms which have non-zero weight
            global D=D[Non_zero_Index]                            #Update D and Weight_D
            global Weight_D=Weight_D[Non_zero_Index]
            
        
            if iter==K                                                       #Check if the maximum number of iteration is satisfied
                global rep=0                                                 #Discountinue the while loop
                global Terminating="The iteration limit is reached"
                global opt_val=QP(x_k, Instance)
                global opt_sol=x_k
            end
    
        end
        return Terminating,iter,opt_val 
    
    end



    
    function FullCorrection_FW_QP(epsil::Float64,K::Int64,Instance)

        ######################################################################################################
        # Function on the Fully-Corrective Frank Wolfe algorithm with exactly line search step size          #
        # Instance is the QP problem                                                                         #
        # epsil is the approximation error                                                                   #
        # K is a reasonable iteration limit                                                                  # 
        # The Fully-Corrective Frank-Wolfe algorithm computes the new iterate x_k+1                          #
        # by reoptimizing the objective function over the convex hull of previous discovered vertices        #                                                                 #
        ######################################################################################################


        x_1=solveLP_StartPoint(Instance) #StartPoint_Two_PhaseSimplex(Instance)       #solveLP_StartPoint(Instance)  #Get the starting point using solveLP_StartPoint or StartPoint_Two_PhaseSimplex
        global x_k=x_1                                         #Plug the initial point
        global iter=0                                          #Initialize the iteration number to be 0
        global rep=1                                           #Binary variabe to control if the while loop should be discountinued
        global opt_val=Inf                                     #Initialize the final objective function value to be 0
        global opt_sol=[]                                      #Initialize the final solution to be empty
        global Terminating=""  
2
         

        while rep==1

            iter=iter+1                                 #Get the number of iterations done
            z_k=solveLP_Toward(x_k,Instance)            #Get the Toward direction at x_k
            d_k=z_k-x_k
    
            if gap(x_k,z_k,Instance) < epsil                             #Check if the stop critirion is satisfied
                Terminating="Termination condition with respect to epsilon is satisfied"      #Get the reason that the algorithm terminated
                opt_sol=x_k                                              #Get the final solution
                opt_val=QP(x_k, Instance)                                #Get the objective function value of the final solution
                break                                                    #Qiut the while loop as the stop critirion is satisfied
            end

            push!(D,z_k)                                                 #Add the new discorved point into set D

                
            x_k=ConvexHull_Opt(D)                  #Compute the new iterate x_k by reoptimizing the objective function over conv{x_1, z_1,z_2,...z_k}

            if iter==K                                                #Check if the maximum number of iteration is satisfied
                rep=0                                                 #Discountinue the while loop
                Terminating="The iteration limit is reached"
                opt_val=QP(x_k, Instance)
                opt_sol=x_k
            end

        end
        return Terminating,iter,opt_val 

    end



    function Pairwise_FW_QP_Debug(epsil::Float64,K::Int64,Instance)

        ######################################################################################################
        # Function on the Pairwise Frank Wolfe algorithm with exactly line search step size                  #
        # Instance is the QP problem                                                                         #
        # epsil is the approximation error                                                                   #
        # K is a reasonable iteration limit                                                                  #                                                                   #
        ######################################################################################################



        x_1= KKT_StartPoint_Debug(Instance) #KKT_StartPoint(Instance) #solveLP_StartPoint(Instance)#KKT_StartPoint(Instance)    ##      #solveLP_StartPoint(Instance)  #Get the starting point using solveLP_StartPoint or StartPoint_Two_PhaseSimplex
        global x_k=x_1                                         #Plug the initial point
        global iter=0                                          #Initialize the iteration number to be 0
        global rep=1                                           #Binary variabe to control if the while loop should be discountinued
        global opt_val=Inf                                     #Initialize the final objective function value to be 0
        global opt_sol=[]                                      #Initialize the final solution to be empty
        global Terminating=""  
    
        
        while rep==1

            #Remember the first iteration is 1
            iter=iter+1    
            println("The Pairwise_FW_QP_Debug with KKT is Starting:\n")                                                #Get the number of iterations done so far
            println("This is the iteration $(iter):")
            
            z_k=solveLP_Toward_Debug(x_k,Instance)                          #Get the Toward direction at x_k
            d_Tk=z_k-x_k
            w_k=solveLP_Away_Debug(x_k,Instance)                            #Get the Away direction at x_k
            d_Ak=x_k-w_k

            gap_value=gap(x_k,z_k,Instance)

            println("The gap is $(gap_value) in this iteration")

            if gap_value < epsil                                                                    #Check if the stop critirion is satisfied
                global Terminating="Termination condition with respect to epsilon is satisfied"     #Get the algorithm termination status
                global opt_sol=x_k                                                                  #Get the final solution
                global opt_val=QP(x_k, Instance)                                                    #Get the objective function value of the final solution
                break                                                                                #Quit the while loop
            end

            
    
            
            d_k=d_Tk+d_Ak                                             #Set the decent direction be combination of the Away direction and Toward direction
            gamma_max=AwayStep_GammaMax(x_k, Instance,d_k)
            gamma_k=linesearchQP(x_k, Instance,d_k, gamma_max)        #Find the exactly step size
            x_k=x_k+gamma_k*d_k                                       #Get the new iterative point
    
            
            Non_zero_Index=findall(x -> x!=0, Weight_D)           #Get all atoms which have non-zero weight
            global D=D[Non_zero_Index]                            #Update D and Weight_D
            global Weight_D=Weight_D[Non_zero_Index]
            
            
            
            if iter==K                                                #Check if the maximum number of iteration is satisfied
                global rep=0                                          #Discountinue the while loop
                global Terminating="The iteration limit is reached"
                global opt_val=QP(x_k, Instance)
                global opt_sol=x_k
            end
    
        end

        println("$(Terminating), $(iter), $(opt_val)", "\n\n\n")

        return Terminating,iter,opt_val 
    
        
    end


    
end






 