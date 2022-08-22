
using DelimitedFiles
import XLSX

folder_vec=["boxqp", "randqp", "globallib", "cuter"]
Name_FW_vec=["CFW", "ASFW", "PFW","ASFW2", "PFW2"]
epsilName_vec=["e2","e3","e4"]      
folder=folder_vec[3]
output_path1="/Users/Mindy/Desktop/Julia/Output/FW_Algorithm_New2/All_In_Text/" 
output_path2="/Users/Mindy/Desktop/Julia/Output/FW_Algorithm_New2/All_In_Excel/" 

for i in 1:5

    Name_FW=Name_FW_vec[i]

    for j in 1:3
        GH=[]
    
        epsilName=epsilName_vec[j]


        cd(output_path1*folder)
     
        open("$(folder)_$(Name_FW)_$(epsilName).txt") do file
            GH=readdlm(file, ',')
        end

         

        cd(output_path2)
        XLSX.openxlsx("$(folder)_output.xlsx", mode="rw") do f
            sheet = f["$(folder)_$(Name_FW)_$(epsilName)"]
            sheet["A7",dim=1]=GH[:,1]
            sheet["B7",dim=1]=GH[:,2]
            sheet["C7",dim=1]=GH[:,3]
            sheet["D7",dim=1]=GH[:,4]
            sheet["E7",dim=1]=GH[:,5]
        end

    end
end





