include("./Variant_FW.jl")
using .MyFW
include("./Utility_Fun.jl")
    using .Myutility_read

file_now="/Users/Mindy/Desktop/Julia/FW_Algorithm_New/"
cd(file_now)

debug_path="/Users/Mindy/Desktop/Debug/file"
cd(debug_path)
mat_file=readdir()[2]

epsil_vec=[1e-2,1e-3,1e-4]
epsil=epsil_vec[1]
K=250

FW_Fun_vec=[Classical_FW_QP, AwayStep_FW_QP, AwayStep_Atoms_FW_QP, Pairwise_FW_QP, Pairwise_Atoms_FW_QP] 
FW_Fun=FW_Fun_vec[5]

#Instance=read_instance(mat_file)

#MyFW.AwayStep_Atoms_FW_QP(epsil,K, Instance)

t = time()
x = 1
y = 2
z = x^2 + y
print(z)


open("hello.txt", "w") do file
    write(file, "$(z) \n")
end


dt = time() - t

 
  open("hello.txt", "a+") do f
    write(f, "$(dt)")
  end