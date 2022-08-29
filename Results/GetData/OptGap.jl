
#####################################################
#This script is for computing the optimality gap    #
######################################################

using LinearAlgebra
using DelimitedFiles
import XLSX
using Statistics
output_path="/Users/Mindy/Desktop/NEW" 
cd(output_path)

io=XLSX.readxlsx("All.xlsx")  
sh=io["Final_Value-KKT"]
all_value_KKT=sh["F4:T246"]
sh1=io["Final_Value-Phase I"]
all_value_Phase=sh1["F4:T246"]
sh2=io["gap_opt"]
glb=sh2["A2:A244"]
close(io)
all_KKT_gap=zeros(243,15).+2
all_Phase_gap=zeros(243,15).+2
all_KKT_check=zeros(243,15).+2
all_Phase_check=zeros(243,15).+2

for j in 1:15
    for i in 1:243

        all_KKT_gap[i,j] = 100*abs(glb[i]-all_value_KKT[i,j])/(max(1.0, abs(glb[i])))
        
    end
end

for j in 1:15
    for i in 1:243

        all_Phase_gap[i,j] = 100*abs(glb[i]-all_value_Phase[i,j])/(max(1.0, abs(glb[i])))
    end
end


pahseI_boxqp=mean(eachrow(all_Phase_gap[1:90,:]))
pahseI_qp=mean(eachrow(all_Phase_gap[91:243,:]))
kkt_boxqp=mean(eachrow(all_KKT_gap[1:90,:]))
kkt_qp=mean(eachrow(all_KKT_gap[91:243,:]))
 
all=vcat(pahseI_boxqp',pahseI_qp',kkt_boxqp',kkt_qp')
round.(all', digits=4)


for j in 1:15
    for i in 1:243

        if abs(glb[i]-all_value_KKT[i,j]) <1e-8
            all_KKT_check[i,j]=1
        else
            all_KKT_check[i,j]=0
        end
 
    end
end

for j in 1:15
    for i in 1:243

        if abs(glb[i]-all_value_Phase[i,j]) <1e-8
            all_Phase_check[i,j]=1
        else
            all_Phase_check[i,j]=0
        end
    end
end


all_Phase_check_Box=all_Phase_check[1:90,:]
all_Phase_check_Gen=all_Phase_check[91:243,:]
all_KKT_check_Box=all_KKT_check[1:90,:]
all_KKT_check_Gen=all_KKT_check[91:243,:]