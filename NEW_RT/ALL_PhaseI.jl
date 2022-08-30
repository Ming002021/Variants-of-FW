#########################################################################
#Use BenchmarkTools to get the running time of  FW algorithm            #
#Starting point obtained by Phase I                                     #
#########################################################################


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
epsil=epsil_vec[1]                                         #Choose epsilon value 
epsilName=epsilName_vec[1]
function_vec=[CFW,ASFW,ASFWA,PFW,PFWA]
fun=function_vec[1]                                        #Choose an algorithm
   
output1_path="/Users/Mindy/Desktop/NEW/mat/$(instance_Type)"     #The directory of storing all problems, i.e. storing "boxqp", "randqp", "globallib" and "cuter" folders                             
cd(output1_path) 
mat_file=readdir()[2]                                            #Select the mat file that will be used

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


model = Model(GLPK.Optimizer)                  #Using GLPK Slover to slove LP
@variable(model, LB[i] <= x[i=1:n] <= UB[i])
@constraint(model, A * x .<= b)
@constraint(model, Aeq * x .== beq)   
@objective(model, Min, 0)
optimize!(model)


x_1= value.(x)                               #Get the starting point

b = @benchmark fun($x_1,$K,$epsil,$A,$Aeq,$b,$beq,$LB,$UB,$Q,$c,$T,$n) evals=10 samples=100 seconds = 10000;
min = minimum(b)
runtimes=min.time/1e9
println("Running Time is $(runtimes)")

output2_path="/Users/Mindy/Desktop/NEW_RT/Text/$(fun)_Phase I/$(instance_Type)"                                
cd(output2_path)

open("$(mat_file)_$(epsilName).txt", "w") do file  
    write(file, "The running time is $(runtimes)")
 end
              
    

