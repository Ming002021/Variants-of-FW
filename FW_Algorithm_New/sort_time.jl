using LinearAlgebra
using DelimitedFiles
import XLSX
per=["Final_Value","Solution_Time","Number_Iteration"]      

Name_FW_vec=["CFW", "ASFW", "ASFW2", "PFW", "PFW2"]
START=["Phase I", "KKT"]
nowwbox= []
nowwg= []
noww=[]

 


Name_FW=Name_FW_vec[5]
#p_fw=per[1]
#p="$(per[1])-$(START[2])"

output_path="/Users/Mindy/Desktop/Comparison/Excel/" 
cd(output_path)

f=XLSX.readxlsx("CFW.xlsx") 
sheet=f["Solution_Time"] 
cfw=sheet["C5:H246"]
close(f)

f=XLSX.readxlsx("ASFW.xlsx") 
sheet=f["Solution_Time"] 
asfw=sheet["C5:H246"]
close(f)
 
f=XLSX.readxlsx("ASFW2.xlsx") 
sheet=f["Solution_Time"] 
asfw2=sheet["C5:H246"]
close(f)
 

f=XLSX.readxlsx("PFW.xlsx") 
sheet=f["Solution_Time"] 
pfw=sheet["C5:H246"]
close(f)
 
f=XLSX.readxlsx("PFW2.xlsx") 
sheet=f["Solution_Time"] 
pfw2=sheet["C5:H246"]
close(f)
 
#
e1_c_a=cfw[:,1] ./asfw[:,1]
e1_c_a2=cfw[:,1] ./asfw2[:,1]
e1_c_p=cfw[:,1] ./pfw[:,1]
e1_c_p2=cfw[:,1] ./pfw2[:,1]
e2_c_a=cfw[:,2] ./asfw[:,2]
e2_c_a2=cfw[:,2] ./asfw2[:,2]
e2_c_p=cfw[:,2] ./pfw[:,2]
e2_c_p2=cfw[:,2] ./pfw2[:,2]
e3_c_a=cfw[:,3] ./asfw[:,3]
e3_c_a2=cfw[:,3] ./asfw2[:,3]
e3_c_p=cfw[:,3] ./pfw[:,3]
e3_c_p2=cfw[:,3] ./pfw2[:,3]

#

 
e1_a_a2=asfw[:,1] ./asfw2[:,1]
e1_a_p=asfw[:,1] ./pfw[:,1]
e1_a_p2=asfw[:,1] ./pfw2[:,1]
e2_a_a2=asfw[:,2] ./asfw2[:,2]
e2_a_p=asfw[:,2] ./pfw[:,2]
e2_a_p2=asfw[:,2] ./pfw2[:,2]
e3_a_a2=asfw[:,3] ./asfw2[:,3]
e3_a_p=asfw[:,3] ./pfw[:,3]
e3_a_p2=asfw[:,3] ./pfw2[:,3]
 #

  
e1_a2_p=asfw2[:,1] ./pfw[:,1]
e1_a2_p2=asfw2[:,1] ./pfw2[:,1]
e2_a2_p=asfw2[:,2] ./pfw[:,2]
e2_a2_p2=asfw2[:,2] ./pfw2[:,2]
e3_a2_p=asfw2[:,3] ./pfw[:,3]
e3_a2_p2=asfw2[:,3] ./pfw2[:,3]

#

 
e1_p_p2=pfw[:,1] ./pfw2[:,1] 
e2_p_p2=pfw2[:,2] ./pfw2[:,2]
e3_p_p2=pfw2[:,3] ./pfw[:,3]
 
##################

#
ke1_c_a=cfw[:,4] ./asfw[:,4]
ke1_c_a2=cfw[:,4] ./asfw2[:,4]
ke1_c_p=cfw[:,4] ./pfw[:,4]
ke1_c_p2=cfw[:,4] ./pfw2[:,4]
ke2_c_a=cfw[:,5] ./asfw[:,5]
ke2_c_a2=cfw[:,5] ./asfw2[:,5]
ke2_c_p=cfw[:,5] ./pfw[:,5]
ke2_c_p2=cfw[:,5] ./pfw2[:,5]
ke3_c_a=cfw[:,6] ./asfw[:,6]
ke3_c_a2=cfw[:,6] ./asfw2[:,6]
ke3_c_p=cfw[:,6] ./pfw[:,6]
ke3_c_p2=cfw[:,6] ./pfw2[:,6]

#
ke1_a_a2=asfw[:,4] ./asfw2[:,4]
ke1_a_p=asfw[:,4] ./pfw[:,4]
ke1_a_p2=asfw[:,4] ./pfw2[:,4]
ke2_a_a2=asfw[:,5] ./asfw2[:,5]
ke2_a_p=asfw[:,5] ./pfw[:,5]
ke2_a_p2=asfw[:,5] ./pfw2[:,5]
ke3_a_a2=asfw[:,6] ./asfw2[:,6]
ke3_a_p=asfw[:,6] ./pfw[:,6]
ke3_a_p2=asfw[:,6] ./pfw2[:,6]

 
 #

  
 ke1_a2_p=asfw2[:,4] ./pfw[:,4]
 ke1_a2_p2=asfw2[:,4] ./pfw2[:,4]
 ke2_a2_p=asfw2[:,5] ./pfw[:,5]
 ke2_a2_p2=asfw2[:,5] ./pfw2[:,5]
 ke3_a2_p=asfw2[:,6] ./pfw[:,6]
 ke3_a2_p2=asfw2[:,6] ./pfw2[:,6]

#

 
 ke1_p_p2=pfw[:,4] ./pfw2[:,4]
 ke2_p_p2=pfw[:,5] ./pfw2[:,5]
 ke3_p_p2=pfw[:,6] ./pfw2[:,6]






####################finish phase i
e1_phase_boxqp=[mean(e1_c_a[1:90]),mean(e1_c_a2[1:90]),mean(e1_c_p[1:90]),mean(e1_c_p2[1:90]), mean(e1_a_a2[1:90]), mean(e1_a_p[1:90]), 
mean(e1_a_p2[1:90]),mean(e1_a2_p[1:90]),mean(e1_a2_p2[1:90]),mean(e1_p_p2[1:90])]*100

e1_phase_gqp=[mean(e1_c_a[91:242]),mean(e1_c_a2[91:242]),mean(e1_c_p[91:242]),mean(e1_c_p2[91:242]), mean(e1_a_a2[91:242]), mean(e1_a_p[91:242]), 
mean(e1_a_p2[91:242]),mean(e1_a2_p[91:242]),mean(e1_a2_p2[91:242]),mean(e1_p_p2[91:242])]*100
 
e2_phase_boxqp=[mean(e2_c_a[1:90]),mean(e2_c_a2[1:90]),mean(e2_c_p[1:90]),mean(e2_c_p2[1:90]), mean(e2_a_a2[1:90]), mean(e2_a_p[1:90]), 
mean(e2_a_p2[1:90]),mean(e2_a2_p[1:90]),mean(e2_a2_p2[1:90]),mean(e2_p_p2[1:90])]*100

e2_phase_gqp=[mean(e2_c_a[91:242]),mean(e2_c_a2[91:242]),mean(e2_c_p[91:242]),mean(e2_c_p2[91:242]), mean(e2_a_a2[91:242]), mean(e2_a_p[91:242]), 
mean(e2_a_p2[91:242]),mean(e2_a2_p[91:242]),mean(e2_a2_p2[91:242]),mean(e2_p_p2[91:242])]*100
 
e3_phase_boxqp=[mean(e3_c_a[1:90]),mean(e3_c_a2[1:90]),mean(e3_c_p[1:90]),mean(e3_c_p2[1:90]), mean(e3_a_a2[1:90]), mean(e3_a_p[1:90]), 
mean(e3_a_p2[1:90]),mean(e3_a2_p[1:90]),mean(e3_a2_p2[1:90]),mean(e3_p_p2[1:90])]*100

e3_phase_gqp=[mean(e3_c_a[91:242]),mean(e3_c_a2[91:242]),mean(e3_c_p[91:242]),mean(e3_c_p2[91:242]), mean(e3_a_a2[91:242]), mean(e3_a_p[91:242]), 
mean(e3_a_p2[91:242]),mean(e3_a2_p[91:242]),mean(e3_a2_p2[91:242]),mean(e3_p_p2[91:242])]*100
 


ke1_phase_boxqp=[mean(ke1_c_a[1:90]),mean(ke1_c_a2[1:90]),mean(ke1_c_p[1:90]),mean(ke1_c_p2[1:90]), mean(ke1_a_a2[1:90]), mean(ke1_a_p[1:90]), 
mean(ke1_a_p2[1:90]),mean(ke1_a2_p[1:90]),mean(ke1_a2_p2[1:90]),mean(ke1_p_p2[1:90])]*100

ke1_phase_gqp=[mean(ke1_c_a[91:242]),mean(ke1_c_a2[91:242]),mean(ke1_c_p[91:242]),mean(ke1_c_p2[91:242]), mean(ke1_a_a2[91:242]), mean(ke1_a_p[91:242]), 
mean(ke1_a_p2[91:242]),mean(ke1_a2_p[91:242]),mean(ke1_a2_p2[91:242]),mean(ke1_p_p2[91:242])]*100
 
ke2_phase_boxqp=[mean(ke2_c_a[1:90]),mean(ke2_c_a2[1:90]),mean(ke2_c_p[1:90]),mean(ke2_c_p2[1:90]), mean(ke2_a_a2[1:90]), mean(ke2_a_p[1:90]), 
mean(ke2_a_p2[1:90]),mean(ke2_a2_p[1:90]),mean(ke2_a2_p2[1:90]),mean(ke2_p_p2[1:90])]*100

ke2_phase_gqp=[mean(ke2_c_a[91:242]),mean(ke2_c_a2[91:242]),mean(ke2_c_p[91:242]),mean(ke2_c_p2[91:242]), mean(ke2_a_a2[91:242]), mean(ke2_a_p[91:242]), 
mean(ke2_a_p2[91:242]),mean(ke2_a2_p[91:242]),mean(ke2_a2_p2[91:242]),mean(ke2_p_p2[91:242])]*100
 
ke3_phase_boxqp=[mean(ke3_c_a[1:90]),mean(ke3_c_a2[1:90]),mean(ke3_c_p[1:90]),mean(ke3_c_p2[1:90]), mean(ke3_a_a2[1:90]), mean(ke3_a_p[1:90]), 
mean(ke3_a_p2[1:90]),mean(ke3_a2_p[1:90]),mean(ke3_a2_p2[1:90]),mean(ke3_p_p2[1:90])]*100

ke3_phase_gqp=[mean(ke3_c_a[91:242]),mean(ke3_c_a2[91:242]),mean(ke3_c_p[91:242]),mean(ke3_c_p2[91:242]), mean(ke3_a_a2[91:242]), mean(ke3_a_p[91:242]), 
mean(ke3_a_p2[91:242]),mean(ke3_a2_p[91:242]),mean(ke3_a2_p2[91:242]),mean(ke3_p_p2[91:242])]*100
 
now=hcat(ke3_phase_boxqp)'

println(round.(now;digits=2))