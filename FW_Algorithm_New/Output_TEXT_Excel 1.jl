#############################################################################
# This scripts Output_TEXT_Excel 1, Output_TEXT_Excel 2, Output_TEXT_Excel 3#
# and Output_TEXT_Excel 4 are used to organize all output results           #
############################################################################# 


using LinearAlgebra
using  DataFrames
import XLSX

function chagngeType(x)

    l=length(x)

    y=[]

    for i in 1:l

        if typeof(x[i]) == String

            a=parse(Float64, x[i])

            push!(y, a)

        else
            push!(y,x[i])
        end
    end

    return Float64.(y)
end


folder_vec=["boxqp", "randqp", "globallib", "cuter"]
Name_FW_vec=["CFW", "ASFW", "PFW","ASFW2", "PFW2"]
for i in 1:5
Name_FW=Name_FW_vec[i]
performance="Final_Value"

Number_Folder=[90,64,82,6]
sheet1_Number_Folder=[91,65,83,7]
sheet_Number_Folder=[96,70,88,12]
output_path1="/Users/Mindy/Desktop/Julia/Output/FW_Algorithm_New1/All_In_Excel/" 
output_path2="/Users/Mindy/Desktop/Julia/Output/FW_Algorithm_New2/All_In_Excel/" 
global file_name_vec=[]
global LP_e2_vec=[]
global LP_e3_vec=[]
global LP_e4_vec=[]
global KKT_e2_vec=[]
global KKT_e3_vec=[]
global KKT_e4_vec=[]
for i in 1:4
    folder=folder_vec[i]


    cd(output_path1)
    xf=XLSX.readxlsx("$(folder)_output.xlsx")
    file_name=xf["$(folder)!A2:A$(sheet1_Number_Folder[i])"]
    global file_name_vec=vcat(file_name_vec,file_name)
    #push!(file_name_vec, file_name)

    LP_e2=xf["$(folder)_$(Name_FW)_e2!D7:D$(sheet_Number_Folder[i])"] #ERunTime, D final value, C number iteration
    LP_e3=xf["$(folder)_$(Name_FW)_e3!D7:D$(sheet_Number_Folder[i])"]
    LP_e4=xf["$(folder)_$(Name_FW)_e4!D7:D$(sheet_Number_Folder[i])"]
    global LP_e2_vec=vcat(LP_e2_vec, LP_e2)
    global LP_e3_vec=vcat(LP_e3_vec, LP_e3)
    global LP_e4_vec=vcat(LP_e4_vec, LP_e4)
    #push!(LP_e2_vec, LP_e2)
    #push!(LP_e3_vec, LP_e3)
    #push!(LP_e4_vec, LP_e4)

    close(xf)

    cd(output_path2)
    xf2=XLSX.readxlsx("$(folder)_output.xlsx")
     

    KKT_e2=xf2["$(folder)_$(Name_FW)_e2!D7:D$(sheet_Number_Folder[i])"] #RunTime
    KKT_e3=xf2["$(folder)_$(Name_FW)_e3!D7:D$(sheet_Number_Folder[i])"]
    KKT_e4=xf2["$(folder)_$(Name_FW)_e4!D7:D$(sheet_Number_Folder[i])"]
    global KKT_e2_vec=vcat(KKT_e2_vec, KKT_e2)
    global KKT_e3_vec=vcat(KKT_e3_vec, KKT_e3)
    global KKT_e4_vec=vcat(KKT_e4_vec, KKT_e4)
    close(xf2)


end

file=vec(file_name_vec)
LPe2=vec(LP_e2_vec)
LPe3=vec(LP_e3_vec)
LPe4=vec(LP_e4_vec)
KKTe2=vec(KKT_e2_vec)
KKTe3=vec(KKT_e3_vec)
KKTe4=vec(KKT_e4_vec)
 


filena=String.(file)

KKTe2=chagngeType(KKTe2)
KKTe3=chagngeType(KKTe3)
KKTe4=chagngeType(KKTe4)

LPe2=chagngeType(LPe2)
LPe3=chagngeType(LPe3)
LPe4=chagngeType(LPe4)


l=242

open("$(Name_FW)_$(performance).txt", "w") do file
    
    for i in 1:l
        filen=filena[i]

        write(file, "$(filen), $(LPe2[i]), $(LPe3[i]),$(LPe4[i]),$(KKTe2[i]),$(KKTe3[i]),$(KKTe4[i])", "\n")
    end
     

end   


end

 






