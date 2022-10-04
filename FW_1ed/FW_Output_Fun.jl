__precompile__()


#################################################################
#This script gives the following:                               #
# module MyFinal_FW_Output                                      #
# 	function output_result_Text                                 #
# 	function Final_FW_Output_Text                               #   
#   function FW_Output_For_DataFrame                            #
# module MyAnother_FW_Output                                    #
# 	function Another_output_result_text                         #
#   function Final_FW_Output_Text_Sec                           #
#################################################################  


module MyFinal_FW_Output

    include("./Variant_FW.jl")
    using .MyFW
    include("./Utility_Fun.jl")
    using .Myutility_read
   #using .Myutility_FiniteBound
     

    using  DataFrames

    export output_result_Text
    export Final_FW_Output_Text
    export FW_Output_For_DataFrame

    function output_result_Text(Name_FW, FW_Fun, mat_file,epsil,K, Instance)

		#########################################################################################################################
        # FW_Fun is the the algorithm function in Variant_FW.jl script                                                          #
		# Name_FW is the name of the algorithm used and is used to name the output text file                                    #
        # mat_file is the name of the mat file used  and is used to name the output text file                                   #
        # epsil is a vector of diffrent Approximation errors                                                                    #
        # K is the iteration limit                                                                                              #
        # Instance =read_instance(mat_file)                                                                                     #
        # Output all result to a text file                                                                                      #
		#########################################################################################################################

		l=length(epsil)                                              
	
		open("$(Name_FW)_output_$(mat_file).txt", "w") do file
			write(file, "$(Name_FW) Algorithm","\n")
			write(file, "MAT name: ", mat_file,"\n")
			write(file,"Maximum number of iteration K: $(K)", "\n")
			for i in 1:l
				(TerminatStaus,iterNum,final_val)=FW_Fun(epsil[i],K, Instance)
				timeRun=@elapsed FW_Fun(epsil[i],K, Instance)       #Get the total solution time
				write(file,"----------------------------------\n")
				write(file, "Approximation error : $(epsil[i])", "\n")
				write(file, "Total solution time in seconds: $(timeRun) ",  "\n")
				write(file, "Termination Status: $(TerminatStaus) ",  "\n")
				write(file, "The number of iteration: $(iterNum) ",  "\n")
				write(file, "The objective function value of the final solution when the algorithm terminated: $(final_val) ",  "\n")
				end
	
		end
	end


    function Final_FW_Output_Text(class_path, FW_Name_path, Name_FW, FW_Fun, epsil, K, i)

        ##########################################################################################
        # class_path="/boxqp", "/randqp", "/globallib" or "/cuter"                               #
        # FW_Name_path="/FCFW", "/CFW", "/ASFW" OR "/PSW"                                        #
        # Name_FW="FCFW", "CFW", "ASFW" OR "PSW"                                                 #
        # FW_Fun=FullCorrection_FW_QP, Classical_FW_QP, AwayStep_FW_QP OR Pairwise_FW_QP         #
        # epsil=[1e-2,1e-3,1e-4], a vector of diffrent Approximation errors                      #                                                  #
        # K=250                                                                                  #
        # i is the index of MAT files                                                            #
        ##########################################################################################


        file_now="/Users/Mindy/Desktop/Julia/FW_Algorithm_New"            #Go to the directory storing these julia scripts
        cd(file_now)
        mat_path="/Users/Mindy/Desktop/Julia/mat"                         #The directory of storing all problems, i.e. storing "boxqp", "randqp", "globallib" and "cuter" folders
        output_path="/Users/Mindy/Desktop/Julia/Output/FW_Algorithm_New/First" 

        cd(mat_path*class_path)                                           #Go to the folder used, i.e. "boxqp", "randqp", "globallib" or  "cuter" folders
        mat_file=readdir()[i]                                             #Select the mat file that will be used
        Instance=read_instance(mat_file)                                  #Reading all problem data from this mat file 
                                   
        cd(output_path*FW_Name_path*class_path)                           #Go to the folder used to store output text files
        output_result_Text(Name_FW, FW_Fun, mat_file,epsil,K, Instance) 

        #try 
            #if Finite_LBUB(Instance) == true

                #cd(output_path*FW_Name_path*class_path)                    #Go to the folder used to store output text files
                #output_result_Text(Name_FW, FW_Fun, mat_file,epsil,K, Instance) 
            #else
                #error("WRONG: UB or LB is infinite")
            #end
        
        #catch e
            #println(e)
        
        #end

    end


    function FW_Output_For_DataFrame(FW_Fun,Name_FW,class_path,epsil,K)

        ##########################################################################################
        # FW_Fun=FullCorrection_FW_QP, Classical_FW_QP, AwayStep_FW_QP OR Pairwise_FW_QP         #
        # Name_FW="FCFW", "CFW", "ASFW" OR "PSW"                                                 #
        # class_path="/boxqp", "/randqp", "/globallib" or "/cuter"                               #
        # epsil=1e-2,1e-3 or 1e-4, an Approximation error                                        #
        # K=250                                                                                  #
        # This function is used to abtain four arrays, which are  All_fileName that includes     # 
        # all MAT name in this folder, All_TerTerminatStaus, All_iterNum, All_final_val,         #
        # All_timeRun that includes termination status of each MAT file                          #  
        # Then, organize them into a table                                                       #
        ##########################################################################################


        mat_path="/Users/Mindy/Desktop/Julia/mat"                  #The directory of storing all problems, i.e. storing "boxqp", "randqp", "globallib" and "cuter" folders
    
        cd(mat_path*class_path)                                    #Go to the folder used, i.e. "boxqp", "randqp", "globallib" or  "cuter" folders
    
        l=length(readdir())                                        #Collect every mat_file
        file_Vec=readdir()[1:l]                                    
    
        global All_fileName=[]                                     #Initialization
        global All_TerminatStaus=[]
        global All_iterNum=[]
        global All_final_val=[]
        global All_timeRun=[]

    
        for i in 2:l                                                #Since ther is a hidden .DS_Store file in boxqp, randqp and globallib, the starting index should be 2
            Instance=read_instance(file_Vec[i])                     #Get the instance
            try 
                if Finite_LBUB(Instance) == true                    #None of the elements is LB and UB is infinity

                    (TerminatStaus,iterNum,final_val)=FW_Fun(epsil,K, Instance)
                    timeRun=@elapsed FW_Fun(epsil,K, Instance)      #Get the total solution time
                    push!(All_fileName, file_Vec[i])                
                    push!(All_TerminatStaus, TerminatStaus)
                    push!(All_iterNum, iterNum)
                    push!(All_final_val, final_val)
                    push!(All_timeRun, timeRun)
                    
                else
                    error("WRONG: UB or LB is infinite")
                end
            
            catch e
                println(e)
            
            end
            
        end

        df = DataFrames.DataFrame(File=All_fileName, Termination= All_TerminatStaus, Iteration=All_iterNum, FinalValue= All_final_val, RunTime=All_timeRun)

        rename!(df, "Termination"=>"$(Name_FW)_Termination", "Iteration"=>"$(Name_FW)_Iteration","FinalValue"=>"$(Name_FW)_FinalValue", "RunTime"=>"$(Name_FW)_RunTime")
        

        return df
    
    end

end




module MyAnother_Final_FW_Output

    include("./Variant_FW.jl")
    using .MyFW
    include("./Utility_Fun.jl")
    using .Myutility_read
    using .Myutility_FiniteBound



    export Another_output_result_text
    export Final_FW_Output_Text_Sec


    function Another_output_result_text(FW_Fun,Name_FW,mat_file,folder,epsil,epsilName,K, Instance)

        ############################################################################################
		# FW_Fun is the the algorithm function in Variant_FW.jl script                             # 
        # Name_FW is the name of the algorithm used and is used to name the output text file       #                       
        # mat_file is the name of the mat file used                                                #
        # folder is the one containing mat_file given and is used to name the output text file     #
        # epsil is the Approximation error used                                                    #
        # epsilName is used to name the output text file                                           #
        # K is the iteration limit                                                                 #
        # Instance =read_instance(mat_file)                                                        #
        # Output all result to a text file                                                         #
		############################################################################################


        output_path="/Users/Mindy/Desktop/Julia/Output/FW_Algorithm_New2/All_In_Text"                                
        cd(output_path*"/$(folder)")                                                                    #Go to the directory used to store output text files
    
        open("$(folder)_$(Name_FW)_$(epsilName).txt", "a+") do file                                     #After giving the values of epsil and K, and mat file and algorithm used for implemention, write the output to a text file
            (TerminatStaus,iterNum,final_val)=FW_Fun(epsil,K, Instance)
            timeRun=@elapsed FW_Fun(epsil,K, Instance)      #Get the total solution time for execute one time algorithm
                                                            #This running time contains the time for solving the starting point
                                                            #Will not use this running time because it is not accurate
                                                            #Use benchmarktools to get more accurate result
            write(file, "$(mat_file), $(TerminatStaus), $(iterNum), $(final_val), $(timeRun)", "\n")
        end
    
        
    end



    function Final_FW_Output_Text_Sec(FW_Fun,Name_FW,mat_file,folder,epsil,epsilName,K)

        ##########################################################################################
        # FW_Fun=FullCorrection_FW_QP, Classical_FW_QP, AwayStep_FW_QP OR Pairwise_FW_QP         #
        # Name_FW="FCFW", "CFW", "ASFW" OR "PSW"                                                 #
        # mat_file is the name of the mat file used                                              #
        # folder="boxqp", "randqp", "globallib" or "cuter"                                       #               
        # epsil=1e-2,1e-3 or 1e-4, an Approximation error                                        #
        # K=250                                                                                  #
        # epsilName_vec="e2","e3" or "e4", i.e. "e2" means 1e-2 is used                          #
        #                                                                                        #                                        #
        # After giving the values of epsil and K, and folder and algorithm used for implemention,#
        # write the output result of the mat file in this folder to a text file                  # 
        ##########################################################################################

        mat_path="/Users/Mindy/Desktop/Julia/mat"
        class_path="/$(folder)"                   
        cd(mat_path*class_path)                 #Go to the folder used, i.e. "boxqp", "randqp", "globallib" or  "cuter" folders

        Instance=read_instance(mat_file)

        


        Another_output_result_text(FW_Fun,Name_FW,mat_file,folder,epsil,epsilName,K, Instance)

         #try 
            #if Finite_LBUB(Instance) == true   
                #Another_output_result_text(FW_Fun,Name_FW,mat_file,folder,epsil,epsilName,K, Instance)
                

            #else 
                #error("WRONG: UB or LB is infinite")
            #end
        #catch e
            #println(e)
        #end
      
    end
    
    

end




##################################
###cd("/Users/Mindy/Desktop/Julia/Output//FW_Algorithm_New/"*folder)

#XLSX.openxlsx("$(folder)_output.xlsx", mode="rw") do xf
    #sheet = xf["$(folder)"]
    #XLSX.writetable!(sheet, df, anchor_cell=XLSX.CellRef("P6"))
#end
