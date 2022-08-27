include("./Basic_Functions.jl")
using .MyBasic
include("./Utility_Fun.jl")
using .Myutility_read
using .Myutility_AwayStep_Max   
using .Myutility_LineSearch
using GLPK
using JuMP
using LinearAlgebra
using BenchmarkTools

function CFW(x_1,K,epsil,A,Aeq,b,beq,LB,UB,Q,c,T,n)

 
    global x_k=x_1                                         #Plug the initial point
    global iter=0                                          #Initialize the iteration number to be 0
    global rep=1                                           #Binary variabe to control if the while loop should be discountinued
    global opt_val=Inf                                     #Initialize the final objective function value to be 0
    global opt_sol=[]                                      #Initialize the final solution to be empty
    global Terminating="" 

    while rep==1

#Remember the first iteration is 1
        iter=iter+1    

        modelT = Model(GLPK.Optimizer)
        @variable(modelT, y[1:n])
        @constraint(modelT, LB .<= y .<= UB)
        @constraint(modelT, Aeq * y .== beq)
        @constraint(modelT, A * y .<= b)
        @objective(modelT, Min, (Q*x_k+c)' * y)
        optimize!(modelT)

        z_k= value.(y)                         #Get the Toward direction at x_k

        d_k=z_k-x_k

        gap_value=(-(Q*x_k+c))'*d_k


        if gap_value < epsil                                                      #Check if the stop critirion is satisfied

            Terminating="Termination condition with respect to epsilon is satisfied"   #Get the algorithm termination status
            opt_sol=x_k                                           #Get the final solution
            opt_val=c' * x_k +0.5*(x_k'*Q *x_k)+T[1,1]                                  #Get the objective function value of the final solution
            break                                                        #Quit the while loop
        end

                            #Set the decent direction be combination of the Away direction and Toward direction

        gamma_max=1.0
        gamma_k=linesearchQP(x_k, Q,c, T, d_k, gamma_max)   #Find the exactly step size


        x_k=x_k+gamma_k*d_k                                #Get the new iterative point
        value_now=c' * x_k +0.5*(x_k'*Q *x_k)+T[1,1] 



        if iter==K                                                 
            rep=0                                           
            Terminating="The iteration limit is reached"
            opt_val=value_now
            opt_sol=x_k
        end


    end

    return opt_val

end

K=250
epsil_vec=[1e-2,1e-3,1e-4]
epsilName_vec=["e2","e3","e4"]  
instance_Type_vec=["BoxQP","CUTEr","Globallib","RandQP"]
instance_Type_length_vec=[90,6,83,64]
instance_Type=instance_Type_vec[3]
instance_Type_length=instance_Type_length_vec[3]
ins=[]
eps=[1 1 1 2 2 2 2 2 2 3]
ins=[9 48 69 9 29 47 48 49 64 9]
len=length(eps)


for j in 1:len
    instance_Type=instance_Type_vec[j]
    instance_Type_length=instance_Type_length_vec[j]


    epsilnum=eps[j]

    epsil=epsil_vec[epsilnum]
    epsilName=epsilName_vec[epsilnum]

    i=ins[j]

        output1_path="/Users/Mindy/Desktop/NEW_RT/mat/$(instance_Type)"                                 
        cd(output1_path) 

        mat_file=readdir()[i]  
        Instance=read_instance(mat_file)    #Go to the directory used to store output text files

        Q   = Instance["Q"] 
        c   = Instance["c"]
        LB  = Instance["LB"]                #x >= LB, i.e. -x <=-LB
        UB  = Instance["UB"]                # x <= UB
        A   = Instance["A"]                 #A*x <=b
        b   = Instance["b"]
        Aeq = Instance["Aeq"]               #Aeq*x <=beq
        beq = Instance["beq"]
        T   = Instance["T"]  
        n   =length(LB)   
    
        #output2_path="/Users/Mindy/Desktop/NEW/Text/CFW_Phase I/"                                
        #cd(output2_path)
    
        try 
    
            model = Model(GLPK.Optimizer)            #Using GLPK Slover to slove LP
            @variable(model, LB[i] <= x[i=1:n] <= UB[i])
            @constraint(model, A * x .<= b)
            @constraint(model, Aeq * x .== beq)   
            @objective(model, Min, 0)
            optimize!(model)
            
            x_1= value.(x)  
        
            b = @benchmark CFW($x_1,$K,$epsil,$A,$Aeq,$b,$beq,$LB,$UB,$Q,$c,$T,$n) evals=10 samples=100 seconds = 10000;
            min = minimum(b)
            runtimes=min.time/1e9
        
            output2_path="/Users/Mindy/Desktop/NEW_RT/Text/CFW_Phase I/$(instance_Type)"                                
            cd(output2_path)

            open("$(mat_file)_$(epsilName).txt", "w") do file  
                write(file, "The running time is $(runtimes)")
            end 
        
        catch 
            output2_path="/Users/Mindy/Desktop/NEW_RT/Text/CFW_Phase I/"                                
            cd(output2_path)
 
              open("CFW_PhaseI.txt", "a+") do file  
                  write(file, " h is $(h) j is $(j) i is $(i) \n")
              end
             
        end


        
     
end



io=open("CFW_PhaseI.txt")  
lines_result=readlines(io)
l=length(lines_result)
forIns_vec=[]
forEPS_VEC=[]
forins_VEC=[]

for i in 1:l
    val_str=split(lines_result[i]," ")
    forIns=parse(Int64, val_str[4])
    forEPS=parse(Int64, val_str[7])
    forins=parse(Int64, val_str[10])
    push!(forIns_vec, forIns)
    push!(forEPS_VEC, forEPS)
    push!(forins_VEC, forins)
end
println(forIns_vec')
println(forEPS_VEC')
println(forins_VEC')


open("CFW_PhaseI.txt","w") do io
end
