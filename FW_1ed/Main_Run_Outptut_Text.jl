
##########################################################################################################
# This script uses output function in the module MyFinal_FW_Output to output the results to text files   #
##########################################################################################################


include("./FW_Output_Fun.jl")
using .MyFinal_FW_Output
include("./Variant_FW.jl")
using .MyFW
#Prepare

class_path_vec=["/boxqp", "/randqp", "/globallib", "/cuter"]
#FW_Name_path_vec=["/CFW", "/ASFW", "/PFW", "/FCFW" ]
#Name_FW_vec=["CFW", "ASFW", "PFW", "FCFW" ]
#FW_Fun_vec=[Classical_FW_QP, AwayStep_FW_QP, Pairwise_FW_QP, FullCorrection_FW_QP]
FW_Name_path_vec=["/CFW", "/ASFW", "/PFW","/ASFWA", "/PFWA" ]
Name_FW_vec=["CFW", "ASFW", "PFW","ASFWA", "PFWA"]
FW_Fun_vec=[Classical_FW_QP,AwayStep_FW_QP, AwayStep_Atoms_FW_QP, Pairwise_FW_QP, Pairwise_Atoms_FW_QP] 
Start_Index=[2,2,2,2]                 #Since ther is a hidden .DS_Store file in boxqp and randqp, the starting index should be 2
End_Index=[91, 65, 84, 6]             #This is the index pointing to the final MAT file

epsil=[1e-2,1e-3,1e-4]
K=250
#Preparation is done

#Implement

for h in 1:1

    class_path=class_path_vec[h]       #Which type of problems I want to implement, boxqp, randqp, globallib or cuter
    SI=Start_Index[h]
    EI=End_Index[h]

    for i in 1:1
    
        FW_Name_path=FW_Name_path_vec[i]
        Name_FW=Name_FW_vec[i]
        FW_Fun=FW_Fun_vec[i]          #Which algorithm I want to implement, Classical_FW_QP, AwayStep_FW_QP, Pairwise_FW_QP or FullCorrection_FW_QP

        for j in SI:EI
    
            Final_FW_Output_Text(class_path, FW_Name_path, Name_FW, FW_Fun, epsil, K, j)
        end
        
    end

end






