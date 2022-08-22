using LinearAlgebra
using DelimitedFiles
import XLSX


per=["Final_Value","Solution_Time","Number_Iteration"]      
 
output_path="/Users/Mindy/Desktop/Comparison/Excel/" 
cd(output_path)
Name_FW_vec=["CFW", "ASFW", "ASFW2", "PFW", "PFW2"]
START=["Phase I", "KKT"]
p_fw=per[2]
p="$(per[2])-$(START[1])"
 
#FOR SULTION TIME PHASE 
 
for i in 1:5
    
    fileN=[]
    value=[]

    Name_FW=Name_FW_vec[i]
    f=XLSX.readxlsx("$(Name_FW).xlsx") 
    sheet=f["$(p_fw)"] 
    fileN=sheet["B5:B247"]
    value=sheet["C5:E247"]
    #value=sheet["F5:H247"]



    XLSX.openxlsx("All.xlsx", mode="rw") do io
        sh = io["$(p)"]
    
        if i==1
    
            sh["D4",dim=1]=fileN[:,1]
             
            sh["F4",dim=1]=value[:,1]
            sh["G4",dim=1]=value[:,2]
            sh["H4",dim=1]=value[:,3]
        
        elseif  i==2
        
            
            sh["I4",dim=1]=value[:,1]
            sh["J4",dim=1]=value[:,2]
            sh["K4",dim=1]=value[:,3]
        
        
        elseif  i==3
        
            
            sh["L4",dim=1]=value[:,1]
            sh["M4",dim=1]=value[:,2]
            sh["N4",dim=1]=value[:,3]
        
         
        elseif i==4 
        
            
            sh["O4",dim=1]=value[:,1]
            sh["P4",dim=1]=value[:,2]
            sh["Q4",dim=1]=value[:,3]
        
        else 
        
            
            sh["R4",dim=1]=value[:,1]
            sh["S4",dim=1]=value[:,2]
            sh["T4",dim=1]=value[:,3]
        
        end
    end


    




     
end










     