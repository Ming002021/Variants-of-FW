__precompile__()

###########################################
#This script gives the following:         #
# module MyBasic                          #
# 	function QP                           #
# 	function gradient                     #   
# 	function gap                          #
#   function ConvexHull_Opt (Not used)    #
###########################################



module MyBasic

using LinearAlgebra
using JuMP
using GLPK
using LazySets
using Polyhedra
using CDDLib

export QP                               #Used in linesearchQP, Classical_FW_QP, AwayStep_FW_QP, Pairwise_FW_QP, FullCorrection_FW_QP
export gradient                         #Used in solveLP_Toward, solveLP_Away, AwayStep_FW_QP  
export gap                              #Used in Classical_FW_QP, AwayStep_FW_QP, Pairwise_FW_QP, FullCorrection_FW_QP
export ConvexHull_Opt                   #Used in FullCorrection_FW_QP

    function QP(x::Vector{Float64}, Instance)

    ############################################################
    # Solve the Quadratic form function given x, Q and c       #                                                                     #
    ############################################################

        Q    = Instance["Q"]
        c    = Instance["c"]
        T    = Instance["T"]            #T is 1×1 Matrix{Float64}, so set T[1,1] is the constant term 0.5L'QL + c'L
        return   c' * x +0.5*(x'*Q *x)+T[1,1]                                                                                                                               
    end

    


    function gradient(x::Vector{Float64},Instance)

    ############################################################
    # Function to get the gradient of the quadratic form at x  #                                                                     #
    ############################################################


        Q    = Instance["Q"]
        c    = Instance["c"]
        
        return Q*x+c   
    end     
    
    function gap(x::Vector{Float64},z::Vector{Float64},Instance)

    ############################################################
    # Function to get the gap between two vectors x and z      #
    # such that we can use it as the stop critirion            #                                                                     #
    ############################################################
        
        d=(z-x)
        return -gradient(x,Instance)'*d
    end

    

    function  ConvexHull_Opt(ver)

    ############################################################
     # Function to do the optimization over the convex hull of  #
     # a set of vectors known                                   #
    ############################################################



        hull = convex_hull(ver)                  #Given a set of vectors, build the convex hull of them
        p = vrep(hull)                           #V-representation (for Vertices), p contains all vertices in the above convex hull 
                                                 #p = removevredundancy(p, Gurobi.Optimizer)
        p = polyhedron(p)                        #Conversion from the V-representation to the H-representation (for Hyperplanes) 
       
        model = Model(GLPK.Optimizer)
        @variable(model, x[1:fulldim(p)])
        @constraint(model, x in p)
        @objective(model, Min, sum(x))
        optimize!(model)
        return value.(x)                         #x is n x1 Vector{Float64}
      
    end

     

end