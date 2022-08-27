__precompile__()

#######################################################
#This script gives the following:                     #
# module MyLP_module                                  #
# 	function solveLP_StartPoint                       #
#   function KKT_StartPoint                           #
#   function StartPoint_Two_PhaseSimplex (Not used )  #
# 	function solveLP_Toward                           #   
# 	function solveLP_Away                             #
#   function solveLP_Toward_Atoms                     #
#######################################################


module MyLP_module

    include("./Basic_Functions.jl")
    using .MyBasic
    using JuMP
    using GLPK  
    using LinearAlgebra


    export solveLP_StartPoint                      #Used in Classical_FW_QP, AwayStep_FW_QP, Pairwise_FW_QP, FullCorrection_FW_QP
    export KKT_StartPoint                          #Used in Classical_FW_QP, AwayStep_FW_QP, Pairwise_FW_QP, FullCorrection_FW_QP
    export StartPoint_Two_PhaseSimplex             #Another wat to get a start point
    export solveLP_Toward                          #Used in Classical_FW_QP, AwayStep_FW_QP, Pairwise_FW_QP, FullCorrection_FW_QP
    export solveLP_Away                            #Used in AwayStep_FW_QP, Pairwise_FW_QP
    export solveLP_Away_Atoms                      #Used in AwayStep_Atoms_FW_QP, Pairwise_Atoms_FW_QP
    #export KKT_StartPoint_Debug                   #Used in Classical_FW_QP, AwayStep_FW_QP, Pairwise_FW_QP, FullCorrection_FW_QP
    #export solveLP_Toward_Debug                   #Used in Classical_FW_QP, AwayStep_FW_QP, Pairwise_FW_QP, FullCorrection_FW_QP
    #export solveLP_Away_Debug                     #Used in AwayStep_FW_QP, Pairwise_FW_QP


    function solveLP_StartPoint(Instance)

        #######################################################################################
        # Function for sloving an LP problem with zero objective function over the            # 
        # feasible region to get the starting point, where A,Aeq,b,beq,LB and UB are elements # 
        # in constraints                                                                      #
        #######################################################################################


        LB   = Instance["LB"]
	    UB   = Instance["UB"]
	    A    = Instance["A"]
	    b    = Instance["b"]
	    Aeq  = Instance["Aeq"]
	    beq  = Instance["beq"]
	     

        n=length(LB)                             #The size of x, i.e, the number of variabels
        model = Model(GLPK.Optimizer)            #Using GLPK Slover to slove LP
        @variable(model, LB[i] <= x[i=1:n] <= UB[i])
        @constraint(model, A * x .<= b)
        @constraint(model, Aeq * x .== beq)   
        @objective(model, Min, 0)
        optimize!(model)

         


        if termination_status(model) != OPTIMAL
            @warn("The model was not solved correctly.")
            return nothing
        end

        return (x = value.(x))                    #x is n x1 Vector{Float64}

    end



    function KKT_StartPoint(Instance)

        #######################################################################################
        # Function that sloves a problem with zero objective function over the                # 
        # KKT conditions (excluding 4) to get the starting point, where A,Aeq,b,beq,LB and UB # 
        # are elements in constraints                                                         # 
        #                                                                                     #
        #######################################################################################

        Q      = Instance["Q"]  
        c      = Instance["c"]  
        LB     = Instance["LB"]                #x >= LB, i.e. -x <=-LB
	    UB     = Instance["UB"]                #x <= UB
	    A      = Instance["A"]                 #A*x <=b
	    b      = Instance["b"]
	    Aeq    = Instance["Aeq"]               #Aeq*x <=beq
	    beq    = Instance["beq"]

        n=length(LB)                           #The size of x, i.e, the number of variabels

        Aieq=  vcat(A, Matrix{Float64}(I, n, n), Matrix{Float64}(-I, n, n)) #Put all inequality constraints together
        bieq=vcat(b, UB, -1*LB )
                                                               #errors occured when some b_i is inf
        ninif_bieq_index=findall(x-> x >-Inf &&  x < Inf,bieq) #Find all elements in bieq which are not infinity

        ninif_Aieq=Aieq[ninif_bieq_index,:]                    
        ninif_bieq=bieq[ninif_bieq_index,:]


                                            
        model = Model(GLPK.Optimizer)         #Using GLPK Slover to slove LP
        @variables(model, begin

        x_free[i=1:n]
        v_free[i=1:size(Aeq,1)]
        w[i=1:size(Aieq,1)] >=0    
        end
        )
         
        @constraints(model, begin

        Q*x_free+c+Aieq'*w-Aeq'*v_free .==0
        Aeq * x_free .== beq
        ninif_Aieq *x_free .<=ninif_bieq
        
        end
        )
        
         
        @objective(model, Min, 0)
        optimize!(model)

         


        if termination_status(model) != OPTIMAL
            @warn("The model was not solved correctly.")
            return nothing
        end

        return (x = value.(x_free))                    #x is n x1 Vector{Float64}

    end



    function StartPoint_Two_PhaseSimplex(Instance)


        #####################################################################################################
        # Do Phase I The Two-Phase Simplex Method to get an initial basic feasible solution of the problem. #
        # This function proceeds as follows:                                                                #
        # 1. For all inequality, all slack variables to bring the constraints into equality form.           #
        # 2.For each constraint in which the slack variable and the right-hand side have opposite signs,    #
        # or in which there is no slack variable,                                                           #
        # add a new artificial variable that has the same sign as the right-hand side.                      #
        # 3. minimize the sum of the artificial variables                                                   #
        #####################################################################################################
        
    
        A = Instance["A"]
        b = Instance["b"]
    
        Aeq = Instance["Aeq"]
        beq = Instance["beq"] #Actually, beq are non-negative after processing read_instance function
    
        UB = Instance["UB"]  #Actually, UB are ones after processing read_instance function
        LB = Instance["LB"]  #Actually, UB are zeros after processing read_instance function
     
        n_UB=length(UB)      #The length of UB, and also the length of LB, and the number of initial variabels
    
        m_rowA=size(A,1)    #The number of rows of A, and also the length of b
        m_rowAeq=size(Aeq,1) #The number of rows of Aeq, and also the length of beq
    
        Non_Neg_b=findall(x->x>=0, b) #The position of elements which are non-negative in b
    
        model = Model(GLPK.Optimizer)
    
        #@variable(model, x[1:n_UB] >=0) #Build the initial variable
        #@variable(model, a_beq[i=1:m_rowAeq]>=0, base_name = "artificial_beq") #Build the artificial variables such that Aqe*x+artificial_beq=beq
        #@variable(model, s_b[i=1:m_rowA]>=0, base_name = "slack_b") #Build the slack variables for constraints A*x <=b
        #@variable(model, a_b[i=1:m_rowA]>=0, base_name = "artificial_b") #Build the artificial variables such that A*x+slack_b+artificial_b=b if some b is negative
        #@variable(model, s_UB[i=1:n_UB]>=0, base_name = "slack_UB") #Build the slack variables for constraints I*x <=UB
        
        #@constraint (model, Aeq * x+a_beq .== beq)   #Since Aeq*x==beq are equality forms, there is no need to bring slack variables into them so we just add artificial variables  such that Aqe*x+artificial_beq=beq
        
        #@constraint (model, x+s_UB .== UB)   #Since UB are ones, positive, only bring slack variables into them to get equality form, I*x+s_UB =UB
        
        #@constraint (model, a_b[Non_Neg_b] .==0) #If b[i] is non-negative, so do not need bring extra artificial variable into this row
    
        #@constraint(model, A* x + s_b-a_b .== b) #A*x+slack_b+artificial_b=b
    
        #Now, all constraints have the standard formulation 
    
        #@objective (model, Min, sum(a_b[i] for i in 1:m_rowA)+sum(a_beq[j] for j in 1:m_rowAeq))
    
        @variables(model, begin
            x[1:n_UB] >=0
            a_beq[i=1:m_rowAeq]>=0
            s_b[i=1:m_rowA]>=0
            a_b[i=1:m_rowA]>=0
            s_UB[i=1:n_UB]>=0
    
        end)
    
        @constraints(model, begin
            Aeq * x+a_beq .== beq
            a_b[Non_Neg_b] .==0
            A* x + s_b-a_b .== b
            x+s_UB .== UB    
        end)
    
        aim=sum(i * a_b[i] for i in 1:m_rowA)+sum(a_beq[j] for j in 1:m_rowAeq)
    
        @objective(model, Min, aim)
    
        optimize!(model)

         

        if termination_status(model) != OPTIMAL
            @warn("The model was not solved correctly.")
            return nothing
        end
    
    
        return (x = value.(x)) 
    
    
    end



    function solveLP_Toward(x::Vector{Float64}, Instance)

        #############################################################################
        # Function that sloves an LP problem to get the Toward direction,           #
        # i.e, get y in feasible region such to miniminze gradient(x,Q,c)' * y      #                                                                #
        #############################################################################
        
        LB   = Instance["LB"]
	    UB   = Instance["UB"]
	    A    = Instance["A"]
	    b    = Instance["b"]
	    Aeq  = Instance["Aeq"]
	    beq  = Instance["beq"]
    


        n=length(LB)
        model = Model(GLPK.Optimizer)
        @variable(model, LB[i] <= y[i=1:n] <= UB[i])
        @constraint(model, Aeq * y .== beq)
        @constraint(model, A * y .<= b)
        @objective(model, Min, gradient(x,Instance)' * y)
        optimize!(model)

         
        @assert termination_status(model) == OPTIMAL

        return (y = value.(y))                        #y is n x1 Vector{Float64}
    end



    function solveLP_Away(x::Vector{Float64}, Instance)
        
        ##########################################################################################
        # Function that sloves an LP problem to get the Away direction with active constraints,  #
        #i.e, get y in feasible region such to miniminze -gradient(x,Q,c)' * y                   #                                                                #
        ##########################################################################################
        

        LB   = Instance["LB"]
	    UB   = Instance["UB"]
	    A    = Instance["A"]
	    b    = Instance["b"]
	    Aeq  = Instance["Aeq"]
	    beq  = Instance["beq"]


        n=length(LB)
        mrow_A=size(A,1)                           #number of inequality in constraints
        model = Model(GLPK.Optimizer)
        @variable(model, y[1:n])

        for i in 1:n
            if abs(x[i]- LB[i]) <= 1e-8 || abs(x[i]- UB[i]) <= 1e-8     #Find which constraint is active
                @constraint(model, y[i] == x[i])                        #for active upper bound or lower bound
            else
                @constraint(model, LB[i] <= y[i] <= UB[i])
            end
        end

        
     
        for i in 1:mrow_A                                  #@constraint(model, A * y .<= b)
            if abs(A[i,:]'* x -b[i]) <=  1e-8              #A[i,:]'* x == b[i]
                @constraint(model, A[i,:]'* y == b[i])     #inequality (i) is active
            else 
            @constraint(model, A[i,:]'* y <= b[i])         #inequality (i) is not active
            end
        end


        @constraint(model, Aeq * y .== beq)              
        @objective(model, Min, -gradient(x,Instance)' * y)
        optimize!(model)
        return (y = value.(y))                             #n x1 Vector{Float64}


    end


    function solveLP_Away_Atoms(x::Vector{Float64}, D,Instance)

        #############################################################################
        # Function that sloves an LP problem to get the Toward direction,           #
        # i.e, get y in feasible region such to miniminze gradient(x,Q,c)' * y      #  
        # Finding the atom in D which minimizes the potential of descent gived by   #
        # -gradient(x,Instance)' * d_Ak                                             #
        # D is an active set, containing the previous discovered search vertices    #
        # in previous iterations                                                    #
        #############################################################################
        
    
        LD=length(D)
        global value_min_Atom=Inf
        global min_Atom=[]
    
        for i in 1:LD
    
            value_f=-gradient(x,Instance)' * D[i]
    
            if value_f <value_min_Atom
                global value_min_Atom = value_f
                global min_Atom=D[i]
            end
    
        end
    
        if value_min_Atom == Inf

            @warn ("No solution in D")
    
            return nothing
        end
    
        return min_Atom
       
    end




    function KKT_StartPoint_Debug(Instance)

        #######################################################################################
        # Function that sloves a problem with zero objective function over the                # 
        # KKT conditions to get the starting point, where A,Aeq,b,beq,LB and UB are elements  # 
        # in constraints                                                                      #
        #######################################################################################

        Q      = Instance["Q"]  
        c      = Instance["c"]  
        LB     = Instance["LB"]                #x >= LB, i.e. -x <=-LB
	    UB     = Instance["UB"]                # x <= UB
	    A      = Instance["A"]                 #A*x <=b
	    b      = Instance["b"]
	    Aeq    = Instance["Aeq"]               #Aeq*x <=beq
	    beq    = Instance["beq"]

        n=length(LB)                          #The size of x, i.e, the number of variabels

        Aieq=  vcat(A, Matrix{Float64}(I, n, n), Matrix{Float64}(-I, n, n)) #Put all inequality constraints together
        bieq=vcat(b, UB, -1*LB )

        ninif_bieq=findall(x-> x >-Inf &&  x < Inf,bieq) #Find all elements in bieq which are not infinity

        ninif_Aieq=Aieq[ninif_bieq,:]


                                            
        model = Model(GLPK.Optimizer)         #Using GLPK Slover to slove LP
        @variables(model, begin

        x_free[i=1:n]
        v_free[i=1:size(Aeq,1)]
        w[i=1:size(Aieq,1)] >=0    
        end
        )
         
        @constraints(model, begin

        Q*x_free+c+Aieq'*w-Aeq'*v_free .==0
        Aeq * x_free .== beq
        ninif_Aieq *x_free .<=ninif_bieq
        
        end
        )
        
         
        @objective(model, Min, 0)
        optimize!(model)
        println("Using KKT method to get a strating point:")
        println("Describing a summary of the model: \n")
        println(solution_summary(model),"\n")


        if termination_status(model) != OPTIMAL
            @warn("The model was not solved correctly.")
            return nothing
        end

        return (x = value.(x_free))                    #x is n x1 Vector{Float64}

    end



    function solveLP_Toward_Debug(x::Vector{Float64}, Instance)

        #############################################################################
        # Function that sloves an LP problem to get the Toward direction,           #
        # i.e, get y in feasible region such to miniminze gradient(x,Q,c)' * y      #                                                                #
        #############################################################################
        
        LB   = Instance["LB"]
	    UB   = Instance["UB"]
	    A    = Instance["A"]
	    b    = Instance["b"]
	    Aeq  = Instance["Aeq"]
	    beq  = Instance["beq"]
    


        n=length(LB)
        model = Model(GLPK.Optimizer)
        @variable(model, LB[i] <= y[i=1:n] <= UB[i])
        @constraint(model, Aeq * y .== beq)
        @constraint(model, A * y .<= b)
        @objective(model, Min, gradient(x,Instance)' * y)
        optimize!(model)

        println("I am sloving an LP problem over feasible region to get the Toward direction now:")
        println("Describing a summary of the model: \n")
        println(solution_summary(model),"\n")


         
         

        return (y = value.(y))                        #y is n x1 Vector{Float64}
    end


    function solveLP_Away_Debug(x::Vector{Float64}, Instance)
        
        ##########################################################################################
        # Function that sloves an LP problem to get the Away direction with active constraints,  #
        #i.e, get y in feasible region such to miniminze -gradient(x,Q,c)' * y                   #                                                                #
        ##########################################################################################
        

        LB   = Instance["LB"]
	    UB   = Instance["UB"]
	    A    = Instance["A"]
	    b    = Instance["b"]
	    Aeq  = Instance["Aeq"]
	    beq  = Instance["beq"]


        n=length(LB)
        mrow_A=size(A,1)                           #number of inequality in constraints
        model = Model(GLPK.Optimizer)
        @variable(model, y[1:n])

        for i in 1:n
            if abs(x[i]- LB[i]) <= 1e-8 || abs(x[i]- UB[i]) <= 1e-8     #Find which constraint is active
                @constraint(model, y[i] == x[i])                        #for active upper bound or lower bound
            else
                @constraint(model, LB[i] <= y[i] <= UB[i])
            end
        end

        
     
        for i in 1:mrow_A                                  #@constraint(model, A * y .<= b)
            if abs(A[i,:]'* x -b[i]) <=  1e-8              #A[i,:]'* x == b[i]
                @constraint(model, A[i,:]'* y == b[i])     #inequality (i) is active
            else 
            @constraint(model, A[i,:]'* y <= b[i])         #inequality (i) is not active
            end
        end


        @constraint(model, Aeq * y .== beq)              
        @objective(model, Min, -gradient(x,Instance)' * y)
        optimize!(model)

        println("I am sloving an LP problem over feasible region to get the Away direction now:")
        println("Describing a summary of the model: \n")
        println(solution_summary(model),"\n")
        

        return (y = value.(y))                             #n x1 Vector{Float64}


    end


            


end
     
