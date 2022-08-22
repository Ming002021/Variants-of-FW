
#################################################################
# This script outputs to Excel the names of all mat files       #
# whose all elements in LB and UB are not infinity              #
#################################################################  

include("./Utility_Fun.jl")
using .Myutility_read
using .Myutility_FiniteBound
include("./Solve_LP.jl")
using .MyLP_module
include("./Basic_Functions.jl")
using .MyBasic


import XLSX

file_now="/Users/Mindy/Desktop/Julia/FW_Algorithm_New/"
cd(file_now)

folder_vec=["boxqp", "randqp", "globallib", "cuter"]
folder=folder_vec[3]

mat_path="/Users/Mindy/Desktop/Julia/mat"
class_path="/$(folder)"
cd(mat_path*class_path)  
vec_file=readdir()[1:length(readdir())]
l=length(vec_file)




 
global file_all=[]
global Initial_Val_vec=[]
global file_size=[]
global file_sizeA_m_vec=[]
global file_sizeA_n_vec=[]
global file_sizeAeq_m_vec=[]
global file_sizeAeq_n_vec=[]


for i in 1:l
    mat_file=vec_file[i]

    push!(file_all, mat_file)

    #push!(file_finite,  mat_file )
    Instance=read_instance(mat_file)
    #x_1=KKT_StartPoint(Instance)

    #Initial_Val=QP(x_1, Instance)
    #push!(Initial_Val_vec, Initial_Val)

    #Q=Instance["Q"]
    #n_col=size(Q,2)
    #push!(file_size, n_col)

    A=Instance["A"]
    Aeq=Instance["Aeq"]

    if all(y-> y==0,A)==true
        file_sizeA_m=0
        file_sizeA_n=0
    else
        file_sizeA_m=size(A,1)
        file_sizeA_n=size(A,2)
    end
    push!(file_sizeA_m_vec,file_sizeA_m)
    push!(file_sizeA_n_vec,file_sizeA_n)

    if all(y-> y==0,Aeq)==true
        file_sizeAeq_m=0
        file_sizeAeq_n=0
    else
        file_sizeAeq_m=size(Aeq,1)
        file_sizeAeq_n=size(Aeq,2)
    end
    push!(file_sizeAeq_m_vec,file_sizeAeq_m)
    push!(file_sizeAeq_n_vec,file_sizeAeq_n)


     
end


cd("/Users/Mindy/Desktop/Julia/Output//FW_Algorithm_New2/All_In_Excel/")
XLSX.openxlsx("$(folder)_output.xlsx", mode="rw") do f
    sheet = f["$(folder)"]
     
    sheet["E2",dim=1]=file_sizeA_m_vec
    sheet["F2",dim=1]=file_sizeA_n_vec
    sheet["G2",dim=1]=file_sizeAeq_m_vec
    sheet["H2",dim=1]=file_sizeAeq_n_vec
    
end
 

