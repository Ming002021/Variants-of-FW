__precompile__()

###########################################
#This script gives the following:         #
# module Myutility_read                   #
# 	function read_instance                #
# module Myutility_AwayStep_Max           #
# 	function AwayStep_GammaMax            #   
# Myutility_LineSearch                    #
# 	function linesearchQP                 #
#                                         #
###########################################  



module Myutility_read
	
	using MAT
	using LinearAlgebra

	export read_instance                                      

	function read_instance(probfile::String)

		########################################################
		# Function reading all problem data from mat file      #
		# Definition:                                          #
		#    MATRIX  Q, A, Aeq                                 #
		#	 Array   c, b, beq                                 #
		########################################################		
		 

		println("\nReading problem data from file. ")
		println("file: ",probfile)


		fileid = matopen(probfile)
		vars = read(fileid)
		close(fileid)

		LB  = vars["LB"]
		UB  = vars["UB"]
		c   = vars["f"]
		Q   = vars["H"]
		A   = vars["A"]
		b   = vars["b"]
		Aeq = vars["Aeq"]
		beq = vars["beq"]
		   
		
		if isempty(Q) == true || isempty(c)==true

			@warn("WRONG: This problem cannot be processed because Q or c is empty!")
		
		end

		 

		Q=0.5*(Q+Q')                                 #Make sure Q is symmetric
		(mQ,nQ) = size(Q)                            #Check if Q is symmetric
    	if mQ != nQ
			println("Q must be a square matrix!");
        end

		
		n =  length(c)                              #The number of variables
		                              
    	if nQ != n                                  #Check dimension of Q and c
        	println("Dimensions of Q and c are not consistent!")
    	end


		 
        #if LB or UB is empty, Preprocess them
		if isempty(LB) ==true

			LB=-Inf*ones(n,1)
		end

		if isempty(UB) ==true

			UB=Inf*ones(n,1)
		end

		#if A or Aeq is empty, Preprocess them


	    if  isempty(A) ==true
			A=(reshape(resize!(vec(A),1*n),1,n))*0     #When A or Aeq is empty, error occurs when A*x or Aeq*x is computed.
			b=hcat(resize!(vec(b),1)*0)                #So, transforming it into a 1 x nc Matrix{Float64} with all zero elements   
		end                                            #Also, transforming b or beq into 1×1 Matrix{Float64} with 0 element

	    if isempty(Aeq) ==true
			Aeq=(reshape(resize!(vec(Aeq),1*n),1,n))*0
			beq=hcat(resize!(vec(beq),1)*0)
		end




		if typeof(b) == Float64                     #In some instances, b or beq is a Float64 number so that error occurs when
            b = push!([],b)                         #beq - Aeq*LB or b - A*LB is processed because A*LB or Aeq*LB is Matrix{Float64}
        end                                         #Hence, change the type of b or beq into an Array

        if typeof(beq) == Float64
            beq = push!([],beq)
        end
		
		


		println("Reading all varaibles from file is done\n\n")
		println("Preprocess problem data to:")
		println("1) scale variables between 0 and 1")
		println("2) symmetrize Q matrix is positive semi-definite: $(isposdef(Q))")
		println("4) check for infinities in LB and/or UB")

		

		if minimum(LB) > -Inf && maximum(UB) < Inf
			#Without Loss of Generality: imposing the variables into [0,1]
			#L <= x <= U
			#0 <= x-L <= U-L 
			#0 <= (x-L/(U-L) <= 1
			#y = (x-L/(U-L)	
			#x = L + (U-L)y
			#0 <= y <= 1
			#0.5x'Qx + c'x = 0.5(L+(U-L)y)'Q(L+(U-L)y) + c'(L+(U-L)y) =
			#0.5L'QL + c'L + 0.5y'(U-L)Q(U-L)y + (L'Q + c')(U-L)y
			#
			#NewQ = (U-L)Q(U-L)
			#Newc = (U-L)(QL + c)
			#const  = 0.5L'QL + c'L
			#NewA = A*(U-L)
			#Newb = b - A*L
			#0.5x'Qx + c'x = 0.5y'NewQ y + Newc' y + const
			#LB=0, UB=1
			#set UL = diagm(reshape(UB-LB,(n,)))=(U-L)


			UL = diagm(reshape(UB-LB,(n,)))  
			NewQ = UL*Q*UL
			Newc = UL*(Q*LB + c)
			const_ = 0.5*LB'*Q*LB + c'*LB

			#if A or Aeq is not empty, Preprocess them
			 
			NewA = A*UL
			Newb = b - A*LB

			 
			NewAeq = Aeq*UL
			Newbeq = beq - Aeq*LB
			
			
			NewLB = zeros(n,1)
			NewUB = ones(n,1)
			 

			 
		else   #minimum(LB) <= -Inf && maximum(UB) >= Inf, i.e, some elements in LB or UB are infinity

		
			NewA = A
			Newb = b

			NewAeq = Aeq
			Newbeq = beq
			 

			NewQ = Q
			Newc = c
			const_ = reshape([0.0],(1,1))
			NewLB = LB
			NewUB = UB
			 

		end


        #Change them into vectors for convenience
		NewLB=vec(NewLB)
		NewUB=vec(NewUB)
		Newc=vec(Newc)
		Newb=vec(Newb)
		Newbeq=vec(Newbeq)

		#Change all sign of elements in beq to be positive for convenience
		L_beq=size(Newbeq,1)
		for i in 1:L_beq

    		if Newbeq[i] <0
        		Newbeq[i] =Newbeq[i]*-1
        		NewAeq[i,:]=NewAeq[i,:]*-1

    		end    

		end
		Instance = Dict(
			"LB"   => NewLB,           #n×1 Vector{Float64}
			"UB"   => NewUB,           #n×1 Vector{Float64}
			"c"    => Newc,            #n×1 Vector{Float64}
			"Q"    => NewQ,            		#n×n Matrix{Float64}
			"A"    => NewA,            		#mxn Matrix{Float64}
			"b"    => Newb,            #mx1 Vector{Float64}
			"Aeq"  => NewAeq,          		#meq x n Matrix{Float64}
			"beq"  => Newbeq,          #meq x n Vector{Float64}
			"T"    => const_,          		#1×1 Matrix{Float64}
		)
		return Instance

	end


end




module Myutility_AwayStep_Max

	export AwayStep_GammaMax                             #Used in AwayStep_FW_QP, Pairwise_FW_QP

	function AwayStep_GammaMax(x::Vector{Float64}, Instance, d::Vector{Float64})

		##########################################################################################
	    #Computing the step size of the maximum value that x can move along the Away direction   #
		##########################################################################################

		UB   = Instance["UB"]
		LB   = Instance["LB"]
		A    = Instance["A"]
		b    = Instance["b"]

		n=length(LB)
    
    	gamma_max_vec_UB=[]                                 #Find the gamma_max for x^+gamma d^ <=UB
    	for i in 1:n
        	if d[i] <= 1e-8
            	push!(gamma_max_vec_UB, Inf)
        	else
            	push!(gamma_max_vec_UB, (UB[i]-x[i])/d[i])
        	end
    	end
    
    	gamma_max_vec_LB=[]                                 #Find the gamma_max for x^+gamma d^  >= LB
    	for i in 1:n
        	if d[i] >= -1e-8                                #-d[i] <= -1e-8
            	push!(gamma_max_vec_LB, Inf)
        	else
            	push!(gamma_max_vec_LB, (LB[i]-x[i])/d[i])  #(-LB[i]-(-x[i]))/-d[i]
        	end
    	end
    
    	gamma_max_vec_Ab=[]                                 #Find the gamma_max for A(x^+gamma d^)  <= b
    	
        
        v=A * x                                             #Denote the value Ax_k as v
        u=A * d
        len=length(u)
        for i in 1:len
            if u[i] <= 1e-8
                push!(gamma_max_vec_Ab, Inf)
            else
                push!(gamma_max_vec_Ab, (b[i]-v[i])/u[i])
            end
        end
        push!(gamma_max_vec_Ab, Inf)
    
    	gamma_max=minimum([minimum(gamma_max_vec_UB), minimum(gamma_max_vec_LB), minimum(gamma_max_vec_Ab)])

    	return gamma_max                                     #So, the gamma_max is the smallest element in these three Arrays

	end




end
 

module   Myutility_LineSearch

	include("./Basic_Functions.jl")
	using .MyBasic
	using LinearAlgebra

    export linesearchQP                                      #Used in Classical_FW_QP, AwayStep_FW_QP, Pairwise_FW_QP



    function linesearchQP(x::Vector{Float64}, Instance, d::Vector{Float64}, gamma_max::Float64)

		#################################################################################################################
		#After finding a descent direction d along which the objective function is reduced,                             #
		#we determine the a step size that x should move along this direction by using exactly line search strategy.    #
        #gamma_max is the maximum step size that x can move along this direction in the feasible region                 #
		#################################################################################################################
		
		
		
		Q   = Instance["Q"]
		c   = Instance["c"]
		 

        a=0.5*(d'*Q *d)
        b=x'*Q *d+c' * d
        constant= QP(x, Instance)
        if (a>1e-8)

            if (b>= -1e-8)
                gamma_opt=0
            else
                G_min=-b/(2*a)

                if (G_min <= gamma_max)
                    gamma_opt=G_min
                else 
                    gamma_opt=gamma_max
                end

            end

        elseif (a ==0)

            if (b >= -1e-8)
                gamma_opt=0
            else
                gamma_opt=gamma_max
            end

        else

            if(b >= -1e-8)
                G_min=-b/(2*a)

                if (gamma_max <= G_min)
                    gamma_opt=0
                else
                    Fir=constant
                    Sec=a*(gamma_max^2)+b*gamma_max+constant

                    if (Fir <= Sec)
                        gamma_opt=0
                    else
                        gamma_opt=gamma_max
                
                    end

                end

            else 
                gamma_opt=gamma_max
            
			end
        end
		
        return gamma_opt

    end



end


module MyLP_module

    include("./Basic_Functions.jl")
    using .MyBasic
    using JuMP
    using GLPK  
    using LinearAlgebra

    export solveLP_Away_Atoms      


	function solveLP_Away_Atoms(x::Vector{Float64}, D,Instance)

	#############################################################################
	# Function that sloves an LP problem to get the Toward direction,           #
	# i.e, get y in feasible region such to miniminze gradient(x,Q,c)' * y      #  
	# Finding the atom in D that minimizes the potential of descent gived by    #
	# -gradient(x,Instance)' * d_Ak                                             #
	# D is an active set, containing the previous discovered search vertices    #
	# in previous iterations                                                    #
	#############################################################################
	

		LD=length(D)
		global value_min_Atom=Inf
		global min_Atom=[]
		 

		for i in 1:LD

			value_f=(-gradient(x,Instance))' * D[i]

			if value_f < value_min_Atom
				value_min_Atom = value_f
				min_Atom=D[i]
				 
			end

		end

		if value_min_Atom == Inf

			@warn ("No solution in D")

			return nothing
		end

		return min_Atom 
   
	end
end




 