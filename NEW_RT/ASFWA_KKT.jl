############################################################################################
#Use BenchmarkTools to get the running time of Away-steps FW in atomic version             #
#Starting point obtained by KKT conditions                                                 #
############################################################################################

include("./Utility_Fun.jl")
using .Myutility_read
include("./Function.jl")
using .MyFW
using GLPK
using JuMP
using LinearAlgebra
using BenchmarkTools



K=250                                                     #Iteration limit
epsil_vec=[1e-2,1e-3,1e-4]                                #Possible convergence tolerance values, epsilon
epsilName_vec=["e2","e3","e4"]  
#epsil=epsil_vec[1]                                       #Choose epsilon value 
#epsilName=epsilName_vec[1]
epsil_length=3
instance_Type_vec=["BoxQP","CUTEr","Globallib","RandQP"]   #Name of our four sets of instances
instance_Type_length_vec=[90,6,83,64]                      #Number of instances in each set
instance_Type=instance_Type_vec[1]                         #Choose one set
instance_Type_length=instance_Type_length_vec[1]

for j in 1: 1#epsil_length

    epsil=epsil_vec[j]                                     #Choose epsilon value 
    epsilName=epsilName_vec[j]

    for i in 1:1#instance_Type_length     

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
    
    
    
        #output2_path="/Users/Mindy/Desktop/NEW/Text/CFW_Phase I/"                                
        #cd(output2_path)

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

        x_1= value.(x_free)

        b = @benchmark MyFW.ASFWA($x_1,$K,$epsil,$A,$Aeq,$b,$beq,$LB,$UB,$Q,$c,$T,$n) evals=10 samples=100 seconds = 10000;
        min = minimum(b)
        runtimes=min.time/1e9
        
        output2_path="/Users/Mindy/Desktop/NEW_RT/Text/ASFWA_KKT/$(instance_Type)"                                
        cd(output2_path)

        open("$(mat_file)_$(epsilName).txt", "w") do file  
            write(file, "The running time is $(runtimes)")
        end
              
    
    end
    
end