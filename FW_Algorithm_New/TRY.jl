using LinearAlgebra
using DelimitedFiles
import XLSX
per=["Final_Value","Solution_Time","Number_Iteration"]      
 

Name_FW_vec=["CFW", "ASFW", "ASFW2", "PFW", "PFW2"]
START=["Phase I", "KKT"]
#p_fw=per[1]
#p="$(per[1])-$(START[2])"

output_path="/Users/Mindy/Desktop/Comparison/Excel/" 
cd(output_path)


io=XLSX.readxlsx("All.xlsx")  
sh=io["Number_Iteration-KKT"]
all_value_KKT=sh["F4:T245"]
sh1=io["Number_Iteration-Phase I"]
all_value_Phase=sh1["F4:T245"]
close(io)

all_value_Phase_check=zeros(242,15).+2
all_value_KKT_check=zeros(242,15).+2



#phaseI
for i in 1:242
    for j in 1:15
        if all_value_Phase[i,j] ==250
            all_value_Phase_check[i,j]=1
        else
            all_value_Phase_check[i,j]=0
        end
    end
end


#phaseI
for i in 1:242
    for j in 1:15
        if all_value_KKT[i,j] ==250
            all_value_KKT_check[i,j]=1
        else
            all_value_KKT_check[i,j]=0
        end
    end
end


println(Int.(sum(eachrow(all_value_Phase_check ))'))


 








 



