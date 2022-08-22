using LinearAlgebra
using DelimitedFiles
using JuMP
using GLPK
using XLSX
using Statistics

out_path="/Users/Mindy/Desktop/Comparison/Excel/" 
cd(out_path)
io=XLSX.readxlsx("All.xlsx")  
sh=io["gap_opt"]
GLB=sh["A2:A243"]
close(io)
 

ALL_PhaseI=zeros(242,15)
ALL_KKT=zeros(242,15)
 
xo=XLSX.readxlsx("All.xlsx")  
sht=xo["Final_Value-Phase I"]
shtk=xo["Final_Value-KKT"]
all_phaseI=sht["F4:T245"]
all_KKT=shtk["F4:T245"]
close(xo)

#check for phase i

for j in 1:15
    for i in 1:242

        ALL_KKT[i,j] = 100*abs(GLB[i]-all_KKT[i,j])/(max(1.0, abs(GLB[i])))
        
    end
end

for j in 1:15
    for i in 1:242

        ALL_PhaseI[i,j] = 100*abs(GLB[i]-all_phaseI[i,j])/(max(1.0, abs(GLB[i])))
    end
end


 #phase i
 pahseI_P_K_box=mean(eachrow(ALL_PhaseI[1:90,:]))
 pahseI_P_K_gp=mean(eachrow(ALL_PhaseI[91:242,:]))
 KKT_P_K_box=mean(eachrow(ALL_KKT[1:90,:]))
 KKT_P_K_gp=mean(eachrow(ALL_KKT[91:242,:]))



for i in 1:15

    println(mean(ALL_PhaseI[1:90,i]), ",,",pahseI_P_K_box[i] )
     
end
for i in 1:15

    println(mean(ALL_PhaseI[91:242,i]), ",,",pahseI_P_K_gp[i] )
     
end
for i in 1:15

    println(mean(ALL_KKT[1:90,i]), ",,",KKT_P_K_box[i] )
     
end
for i in 1:15

    println(mean(ALL_KKT[91:242,i]), ",,",KKT_P_K_gp[i] )
     
end




CFW_gap=vcat(ALL_PhaseI[:,1],ALL_PhaseI[:,2],ALL_PhaseI[:,3],ALL_KKT[:,1],ALL_KKT[:,2],ALL_KKT[:,3])
ASFW_gap=vcat(ALL_PhaseI[:,4],ALL_PhaseI[:,5],ALL_PhaseI[:,6],ALL_KKT[:,4],ALL_KKT[:,5],ALL_KKT[:,6])
ASFWA_gap=vcat(ALL_PhaseI[:,7],ALL_PhaseI[:,8],ALL_PhaseI[:,9],ALL_KKT[:,7],ALL_KKT[:,8],ALL_KKT[:,9])
PFW_gap=vcat(ALL_PhaseI[:,10],ALL_PhaseI[:,11],ALL_PhaseI[:,12],ALL_KKT[:,10],ALL_KKT[:,11],ALL_KKT[:,12])
PFWA_gap=vcat(ALL_PhaseI[:,13],ALL_PhaseI[:,14],ALL_PhaseI[:,15],ALL_KKT[:,13],ALL_KKT[:,14],ALL_KKT[:,15])


out1_path="/Users/Mindy/Desktop/Debug/" 
cd(out1_path)

XLSX.openxlsx("Comparision_Graph2.xlsx", mode="rw") do io
    sh = io["CFW_gap"]
    sh["B2",dim=1]=CFW_gap
    sh = io["ASFW_gap"]
    sh["B2",dim=1]=CFW_gap
    sh = io["ASFWA_gap"]
    sh["B2",dim=1]=CFW_gap
    sh = io["PFW_gap"]
    sh["B2",dim=1]=CFW_gap
    sh = io["PFWA_gap"]
    sh["B2",dim=1]=CFW_gap
     

end

 
