

instance_Type_vec=["BoxQP","CUTEr","Globallib","RandQP"]
instance_Type_length_vec=[90,6,83,64]
va=["CFW_Phase I","ASFW_Phase I","ASFWA_Phase I","PFW_Phase I","PFWA_Phase I"]


for i in 1:5

    for j in 1:4

instance_Type=instance_Type_vec[j]
instance_Type_length=instance_Type_length_vec[j]

output0_path="/Users/Mindy/Desktop/NEW_RT/mat/$(instance_Type)/"                                
cd(output0_path)
all_file0=readdir()
all_file0_e2=[]
all_file0_e3=[]
all_file0_e4=[]
for i in 1:instance_Type_length
    e2=all_file0[i]*"_e2.txt"
    e3=all_file0[i]*"_e3.txt"
    e4=all_file0[i]*"_e4.txt"
    push!(all_file0_e2,e2)
    push!(all_file0_e3,e3)
    push!(all_file0_e4,e4)
end
 

#check CFW
output1_path="/Users/Mindy/Desktop/NEW_RT/Text/$(va[i])/$(instance_Type)/"                                
cd(output1_path)
all_file1=readdir() 
println("$(length(all_file1))")  

for i in 1:instance_Type_length
    bo=all_file0_e3[i] in all_file1 

    if bo == 0
        println(i)    
    end
end

println("$(va[i])/$(instance_Type) done")

end
end