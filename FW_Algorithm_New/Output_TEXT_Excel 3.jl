using LinearAlgebra
using DelimitedFiles
import XLSX

folder_vec=["boxqp", "randqp", "globallib", "cuter"]
Name_FW_vec=["CFW", "ASFW", "PFW","ASFW2", "PFW2"]
per=["Final_Value","Solution_Time","Number_Iteration"]      
folder=folder_vec[1]
output_path="/Users/Mindy/Desktop/Julia/Output/FW_Algorithm_New2/All_In_Excel/" 

for i in 1:5

    Name_FW=Name_FW_vec[i]
    cd(output_path)

    
    for j in 1:3
        
        GH=[]

        p=per[j]

        open("$(Name_FW)_$(p).txt") do file
            GH=readdlm(file, ',')
        end
         
        XLSX.openxlsx("$(Name_FW).xlsx", mode="rw") do f
            sheet = f["$(p)"]
            sheet["B5",dim=1]=GH[:,1]
            sheet["C5",dim=1]=GH[:,2]
            sheet["D5",dim=1]=GH[:,3]
            sheet["E5",dim=1]=GH[:,4]
            sheet["F5",dim=1]=GH[:,5]
            sheet["G5",dim=1]=GH[:,6]
            sheet["H5",dim=1]=GH[:,7]
        end

        

    end
end



