
##########################################################################################################
# This script uses output function in the module MyAnother_FW_Output to output the results to text files #
##########################################################################################################


include("./FW_Output_Fun.jl")
using .MyAnother_Final_FW_Output
include("./Variant_FW.jl")
using .MyFW

file_now="/Users/Mindy/Desktop/Julia/FW_Algorithm_New/"
cd(file_now)

#Prepare

folder_vec=["boxqp", "randqp", "globallib", "cuter"]
#Name_FW_vec=["CFW", "ASFW", "PFW", "FCFW" ]
#FW_Fun_vec=[Classical_FW_QP, AwayStep_FW_QP, Pairwise_FW_QP, FullCorrection_FW_QP]  #Variants of Frank Wolfe algorithm
Name_FW_vec=["CFW", "ASFW", "ASFWA","PFW", "PFWA"]
FW_Fun_vec=[Classical_FW_QP, AwayStep_FW_QP, AwayStep_Atoms_FW_QP, Pairwise_FW_QP, Pairwise_Atoms_FW_QP]  #Get the starting point using solveLP_StartPoint or StartPoint_Two_PhaseSimplex
epsil_vec=[1e-2,1e-3,1e-4]

epsilName_vec=["e2","e3","e4"]           #"e2" means 1e-2 is used
mat_path="/Users/Mindy/Desktop/Julia/mat"
folder=folder_vec[3]                      #Index is to select which type of problems I want to implement, boxqp, randqp, globallib or cuter
#Name_FW=Name_FW_vec[4]                   #Index is to select which algorithm I want to implement
#FW_Fun= FW_Fun_vec[4]                    #Index is identical to the one in Name_FW
#epsilName=epsilName_vec[3]               #Index is to select which Approximation error  I want to use 
#epsil=epsil_vec[3]                       #Index is identical to the one in epsilName
K=250
class_path="/$(folder)"
cd(mat_path*class_path)
 
vec_file=readdir()[1:length(readdir())]  #Since ther is a hidden .DS_Store file in folder, the starting index should be 2
l=length(vec_file)
#Preparation is done

#Implement

##########################################################################################
# After giving the values of epsil and K, and folder and algorithm used for implemention,#
# write the output result of all mat file in this folder to a single text file           # 
##########################################################################################

for k in 1:1
    Name_FW=Name_FW_vec[k]
    FW_Fun= FW_Fun_vec[k] 

    for j in 1:1

        epsilName=epsilName_vec[j]
        epsil=epsil_vec[j]

        for i in 1:1

            mat_file=vec_file[i]
            Final_FW_Output_Text_Sec(FW_Fun,Name_FW,mat_file,folder,epsil,epsilName,K)
            println(i)
        end
    end
end
