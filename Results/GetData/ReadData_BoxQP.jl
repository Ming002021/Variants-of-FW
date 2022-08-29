import XLSX

instance_Type_vec=["BoxQP","CUTEr","Globallib","RandQP"]
text_path="/Users/Mindy/Desktop/NEW_RT/Text/CFW_Phase I/BoxQP"                                
cd(text_path)
allfile=readdir()[2:271]
#CFW Phase I, BoxQP, e2, e3 and e4
#Num_It_CFW_PhaseI_boxqp_e2=[]
Final_Value_CFW_PhaseI_boxqp_e2=[]
#Num_It_CFW_PhaseI_boxqp_e3=[]
Final_Value_CFW_PhaseI_boxqp_e3=[]
#Num_It_CFW_PhaseI_boxqp_e4=[]
Final_Value_CFW_PhaseI_boxqp_e4=[]

for i in 1:270
    textFile=allfile[i]
    f = open(textFile)
    lines = readlines(f)
    lines_result=lines[end-4]
    val_str=split(lines_result," ")[4]
    val=parse(Float64, val_str)
     

    if mod(i,3) == 1
        #push!(Num_It_CFW_PhaseI_boxqp_e2,numIt)
        push!(Final_Value_CFW_PhaseI_boxqp_e2,val)
    elseif mod(i,3) == 2
        #push!(Num_It_CFW_PhaseI_boxqp_e3,numIt)
        push!(Final_Value_CFW_PhaseI_boxqp_e3,val)
    else
        #push!(Num_It_CFW_PhaseI_boxqp_e4,numIt)
        push!(Final_Value_CFW_PhaseI_boxqp_e4,val)
    end
end


text1_path="/Users/Mindy/Desktop/NEW_RT/Text/CFW_KKT/BoxQP"                               
cd(text_path)
allfile=readdir()[2:271]
#CFW Phase I, BoxQP, e2, e3 and e4
#Num_It_CFW_KKT_boxqp_e2=[]
Final_Value_CFW_KKT_boxqp_e2=[]
#Num_It_CFW_KKT_boxqp_e3=[]
Final_Value_CFW_KKT_boxqp_e3=[]
#Num_It_CFW_KKT_boxqp_e4=[]
Final_Value_CFW_KKT_boxqp_e4=[]

for i in 1:270
    textFile1=allfile[i]
    f1 = open(textFile1)
    lines1 = readlines(f1)
    lines_result1=lines1[1]
    val_str1=split(lines_result1," ")[end]
    val1=parse(Float64, val_str1)

    if mod(i,3) == 1
       # push!(Num_It_CFW_KKT_boxqp_e2,numIt1)
        push!(Final_Value_CFW_KKT_boxqp_e2,val1)
    elseif mod(i,3) == 2
        #push!(Num_It_CFW_KKT_boxqp_e3,numIt1)
        push!(Final_Value_CFW_KKT_boxqp_e3,val1)
    else
        #push!(Num_It_CFW_KKT_boxqp_e4,numIt1)
        push!(Final_Value_CFW_KKT_boxqp_e4,val1)
    end
end


text_path="/Users/Mindy/Desktop/NEW_RT/Text/ASFW_Phase I/BoxQP"                                
cd(text_path)
if readdir()[1] == ".DS_Store"
    allfile=readdir()[2:271]
else
    allfile=readdir()[1:270]
end
#CFW Phase I, BoxQP, e2, e3 and e4
#Num_It_ASFW_PhaseI_boxqp_e2=[]
Final_Value_ASFW_PhaseI_boxqp_e2=[]
#Num_It_ASFW_PhaseI_boxqp_e3=[]
Final_Value_ASFW_PhaseI_boxqp_e3=[]
#Num_It_ASFW_PhaseI_boxqp_e4=[]
Final_Value_ASFW_PhaseI_boxqp_e4=[]

for i in 1:270
    textFile=allfile[i]
    f = open(textFile)
    lines = readlines(f)
    lines_result=lines[1]
    val_str=split(lines_result," ")[end]
    val=parse(Float64, val_str)
    #numIt_str=split(lines_result," ")[end-4]
    #numIt=parse(Int64, numIt_str)

    if mod(i,3) == 1
        #push!(Num_It_ASFW_PhaseI_boxqp_e2,numIt)
        push!(Final_Value_ASFW_PhaseI_boxqp_e2,val)
    elseif mod(i,3) == 2
        #push!(Num_It_ASFW_PhaseI_boxqp_e3,numIt)
        push!(Final_Value_ASFW_PhaseI_boxqp_e3,val)
    else
        #push!(Num_It_ASFW_PhaseI_boxqp_e4,numIt)
        push!(Final_Value_ASFW_PhaseI_boxqp_e4,val)
    end
end





text1_path="/Users/Mindy/Desktop/NEW_RT/Text/ASFW_KKT/BoxQP"                               
cd(text1_path)
if readdir()[1] == ".DS_Store"
    allfile=readdir()[2:271]
else
    allfile=readdir()[1:270]
end
#CFW Phase I, BoxQP, e2, e3 and e4
#Num_It_ASFW_KKT_boxqp_e2=[]
Final_Value_ASFW_KKT_boxqp_e2=[]
#Num_It_ASFW_KKT_boxqp_e3=[]
Final_Value_ASFW_KKT_boxqp_e3=[]
#Num_It_ASFW_KKT_boxqp_e4=[]
Final_Value_ASFW_KKT_boxqp_e4=[]

for i in 1:270

    
    textFile1=allfile[i]
    f1 = open(textFile1)
    lines1 = readlines(f1)
    lines1_result=lines1[1]
    val_str1=split(lines1_result," ")[end]
    val1=parse(Float64, val_str1)

    #numIt_str1=split(lines1_result," ")[end-4]
    #numIt1=parse(Int64, numIt_str1)

    if mod(i,3) == 1
        #push!(Num_It_ASFW_KKT_boxqp_e2,numIt1)
        push!(Final_Value_ASFW_KKT_boxqp_e2,val1)
    elseif mod(i,3) == 2
        #push!(Num_It_ASFW_KKT_boxqp_e3,numIt1)
        push!(Final_Value_ASFW_KKT_boxqp_e3,val1)
    else
        #push!(Num_It_ASFW_KKT_boxqp_e4,numIt1)
        push!(Final_Value_ASFW_KKT_boxqp_e4,val1)
    end
     
    
end


text_path="/Users/Mindy/Desktop/NEW_RT/Text/ASFWA_Phase I/BoxQP"                                
cd(text_path)
if readdir()[1] == ".DS_Store"
    allfile=readdir()[2:271]
else
    allfile=readdir()[1:270]
end
#CFW Phase I, BoxQP, e2, e3 and e4
#Num_It_ASFWA_PhaseI_boxqp_e2=[]
Final_Value_ASFWA_PhaseI_boxqp_e2=[]
#Num_It_ASFWA_PhaseI_boxqp_e3=[]
Final_Value_ASFWA_PhaseI_boxqp_e3=[]
#Num_It_ASFWA_PhaseI_boxqp_e4=[]
Final_Value_ASFWA_PhaseI_boxqp_e4=[]

for i in 1:270
    textFile=allfile[i]
    f = open(textFile)
    lines = readlines(f)
    lines_result=lines[1]
    val_str=split(lines_result," ")[end]
    val=parse(Float64, val_str)
    #numIt_str=split(lines_result," ")[end-4]
    #numIt=parse(Int64, numIt_str)

    if mod(i,3) == 1
        #push!(Num_It_ASFWA_PhaseI_boxqp_e2,numIt)
        push!(Final_Value_ASFWA_PhaseI_boxqp_e2,val)
    elseif mod(i,3) == 2
        #push!(Num_It_ASFWA_PhaseI_boxqp_e3,numIt)
        push!(Final_Value_ASFWA_PhaseI_boxqp_e3,val)
    else
       # push!(Num_It_ASFWA_PhaseI_boxqp_e4,numIt)
        push!(Final_Value_ASFWA_PhaseI_boxqp_e4,val)
    end
end

text1_path="/Users/Mindy/Desktop/NEW_RT/Text/ASFWA_KKT/BoxQP"                               
cd(text1_path)
if readdir()[1] == ".DS_Store"
    allfile=readdir()[2:271]
else
    allfile=readdir()[1:270]
end
#CFW Phase I, BoxQP, e2, e3 and e4
#Num_It_ASFWA_KKT_boxqp_e2=[]
Final_Value_ASFWA_KKT_boxqp_e2=[]
#Num_It_ASFWA_KKT_boxqp_e3=[]
Final_Value_ASFWA_KKT_boxqp_e3=[]
#Num_It_ASFWA_KKT_boxqp_e4=[]
Final_Value_ASFWA_KKT_boxqp_e4=[]

for i in 1:270
    textFile1=allfile[i]
    f1 = open(textFile1)
    lines1 = readlines(f1)
    lines1_result=lines1[1]
    val_str1=split(lines1_result," ")[end]
    val1=parse(Float64, val_str1)
    #numIt_str1=split(lines1_result," ")[end-4]
    #numIt1=parse(Int64, numIt_str1)

    if mod(i,3) == 1
        #push!(Num_It_ASFWA_KKT_boxqp_e2,numIt1)
        push!(Final_Value_ASFWA_KKT_boxqp_e2,val1)
    elseif mod(i,3) == 2
        #push!(Num_It_ASFWA_KKT_boxqp_e3,numIt1)
        push!(Final_Value_ASFWA_KKT_boxqp_e3,val1)
    else
        #push!(Num_It_ASFWA_KKT_boxqp_e4,numIt1)
        push!(Final_Value_ASFWA_KKT_boxqp_e4,val1)
    end
end



text_path="/Users/Mindy/Desktop/NEW_RT/Text/PFWA_Phase I/BoxQP"                                
cd(text_path)
if readdir()[1] == ".DS_Store"
    allfile=readdir()[2:271]
else
    allfile=readdir()[1:270]
end
#CFW Phase I, BoxQP, e2, e3 and e4
#Num_It_PFWA_PhaseI_boxqp_e2=[]
Final_Value_PFWA_PhaseI_boxqp_e2=[]
#Num_It_PFWA_PhaseI_boxqp_e3=[]
Final_Value_PFWA_PhaseI_boxqp_e3=[]
#Num_It_PFWA_PhaseI_boxqp_e4=[]
Final_Value_PFWA_PhaseI_boxqp_e4=[]

for i in 1:270
    textFile=allfile[i]
    f = open(textFile)
    lines = readlines(f)
    lines_result=lines[1]
    val_str=split(lines_result," ")[end]
    val=parse(Float64, val_str)
    #numIt_str=split(lines_result," ")[end-4]
    #numIt=parse(Int64, numIt_str)

    if mod(i,3) == 1
        #push!(Num_It_PFWA_PhaseI_boxqp_e2,numIt)
        push!(Final_Value_PFWA_PhaseI_boxqp_e2,val)
    elseif mod(i,3) == 2
        #push!(Num_It_PFWA_PhaseI_boxqp_e3,numIt)
        push!(Final_Value_PFWA_PhaseI_boxqp_e3,val)
    else
        #push!(Num_It_PFWA_PhaseI_boxqp_e4,numIt)
        push!(Final_Value_PFWA_PhaseI_boxqp_e4,val)
    end
end






text1_path="/Users/Mindy/Desktop/NEW_RT/Text/PFWA_KKT/BoxQP"                               
cd(text1_path)
if readdir()[1] == ".DS_Store"
    allfile=readdir()[2:271]
else
    allfile=readdir()[1:270]
end
#CFW Phase I, BoxQP, e2, e3 and e4
#Num_It_PFWA_KKT_boxqp_e2=[]
Final_Value_PFWA_KKT_boxqp_e2=[]
#Num_It_PFWA_KKT_boxqp_e3=[]
Final_Value_PFWA_KKT_boxqp_e3=[]
#Num_It_PFWA_KKT_boxqp_e4=[]
Final_Value_PFWA_KKT_boxqp_e4=[]

for i in 1:270
    textFile1=allfile[i]
    f1 = open(textFile1)
    lines1 = readlines(f1)
    lines1_result=lines1[1]
    val_str1=split(lines1_result," ")[end]
    val1=parse(Float64, val_str1)
    #numIt_str1=split(lines1_result," ")[end-4]
    #numIt1=parse(Int64, numIt_str1)

    if mod(i,3) == 1
       # push!(Num_It_PFWA_KKT_boxqp_e2,numIt1)
        push!(Final_Value_PFWA_KKT_boxqp_e2,val1)
    elseif mod(i,3) == 2
        #push!(Num_It_PFWA_KKT_boxqp_e3,numIt1)
        push!(Final_Value_PFWA_KKT_boxqp_e3,val1)
    else
        #push!(Num_It_PFWA_KKT_boxqp_e4,numIt1)
        push!(Final_Value_PFWA_KKT_boxqp_e4,val1)
    end
end

text_path="/Users/Mindy/Desktop/NEW_RT/Text/PFW_Phase I/BoxQP"                                
cd(text_path)
if readdir()[1] == ".DS_Store"
    allfile=readdir()[2:271]
else
    allfile=readdir()[1:270]
end
#CFW Phase I, BoxQP, e2, e3 and e4
#Num_It_PFW_PhaseI_boxqp_e2=[]
Final_Value_PFW_PhaseI_boxqp_e2=[]
#Num_It_PFW_PhaseI_boxqp_e3=[]
Final_Value_PFW_PhaseI_boxqp_e3=[]
#Num_It_PFW_PhaseI_boxqp_e4=[]
Final_Value_PFW_PhaseI_boxqp_e4=[]

for i in 1:270
    textFile=allfile[i]
    f = open(textFile)
    lines = readlines(f)
    lines_result=lines[1]
    val_str=split(lines_result," ")[end]
    val=parse(Float64, val_str)
    #numIt_str=split(lines_result," ")[end-4]
    #numIt=parse(Int64, numIt_str)

    if mod(i,3) == 1
        #push!(Num_It_PFW_PhaseI_boxqp_e2,numIt)
        push!(Final_Value_PFW_PhaseI_boxqp_e2,val)
    elseif mod(i,3) == 2
        #push!(Num_It_PFW_PhaseI_boxqp_e3,numIt)
        push!(Final_Value_PFW_PhaseI_boxqp_e3,val)
    else
        #push!(Num_It_PFW_PhaseI_boxqp_e4,numIt)
        push!(Final_Value_PFW_PhaseI_boxqp_e4,val)
    end
end

text1_path="/Users/Mindy/Desktop/NEW_RT/Text/PFW_KKT/BoxQP"                               
cd(text1_path)
if readdir()[1] == ".DS_Store"
    allfile=readdir()[2:271]
else
    allfile=readdir()[1:270]
end
#CFW Phase I, BoxQP, e2, e3 and e4
#Num_It_PFW_KKT_boxqp_e2=[]
Final_Value_PFW_KKT_boxqp_e2=[]
#Num_It_PFW_KKT_boxqp_e3=[]
Final_Value_PFW_KKT_boxqp_e3=[]
#Num_It_PFW_KKT_boxqp_e4=[]
Final_Value_PFW_KKT_boxqp_e4=[]

for i in 1:270
    textFile1=allfile[i]
    f1 = open(textFile1)
    lines1 = readlines(f1)
    lines1_result=lines1[1]
    val_str1=split(lines1_result," ")[end]
    val1=parse(Float64, val_str1)
    #numIt_str1=split(lines1_result," ")[end-4]
    #numIt1=parse(Int64, numIt_str1)

    if mod(i,3) == 1
        #push!(Num_It_PFW_KKT_boxqp_e2,numIt1)
        push!(Final_Value_PFW_KKT_boxqp_e2,val1)
    elseif mod(i,3) == 2
        #push!(Num_It_PFW_KKT_boxqp_e3,numIt1)
        push!(Final_Value_PFW_KKT_boxqp_e3,val1)
    else
        #push!(Num_It_PFW_KKT_boxqp_e4,numIt1)
        push!(Final_Value_PFW_KKT_boxqp_e4,val1)
    end
end




#Num_It_boxqp_KKT=hcat(Num_It_CFW_KKT_boxqp_e2,Num_It_CFW_KKT_boxqp_e3,Num_It_CFW_KKT_boxqp_e4,
#Num_It_ASFW_KKT_boxqp_e2,Num_It_ASFW_KKT_boxqp_e3,Num_It_ASFW_KKT_boxqp_e4,
#Num_It_ASFWA_KKT_boxqp_e2,Num_It_ASFWA_KKT_boxqp_e3,Num_It_ASFWA_KKT_boxqp_e4,
#Num_It_PFW_KKT_boxqp_e2,Num_It_PFW_KKT_boxqp_e3,Num_It_PFW_KKT_boxqp_e4,
#Num_It_PFWA_KKT_boxqp_e2,Num_It_PFWA_KKT_boxqp_e3,Num_It_PFWA_KKT_boxqp_e4,
#)





##Num_It_boxqp_PhaseI= hcat(Num_It_CFW_PhaseI_boxqp_e2,Num_It_CFW_PhaseI_boxqp_e3,Num_It_CFW_PhaseI_boxqp_e4,
#Num_It_ASFW_PhaseI_boxqp_e2,Num_It_ASFW_PhaseI_boxqp_e3,Num_It_ASFW_PhaseI_boxqp_e4,
#Num_It_ASFWA_PhaseI_boxqp_e2,Num_It_ASFWA_PhaseI_boxqp_e3,Num_It_ASFWA_PhaseI_boxqp_e4,
#Num_It_PFW_PhaseI_boxqp_e2,Num_It_PFW_PhaseI_boxqp_e3,Num_It_PFW_PhaseI_boxqp_e4,
#Num_It_PFWA_PhaseI_boxqp_e2,Num_It_PFWA_PhaseI_boxqp_e3,Num_It_PFWA_PhaseI_boxqp_e4,
#)



Final_Value_boxqp_KKT=hcat(Final_Value_CFW_KKT_boxqp_e2,Final_Value_CFW_KKT_boxqp_e3,Final_Value_CFW_KKT_boxqp_e4,
Final_Value_ASFW_KKT_boxqp_e2,Final_Value_ASFW_KKT_boxqp_e3,Final_Value_ASFW_KKT_boxqp_e4,
Final_Value_ASFWA_KKT_boxqp_e2,Final_Value_ASFWA_KKT_boxqp_e3,Final_Value_ASFWA_KKT_boxqp_e4,
Final_Value_PFW_KKT_boxqp_e2,Final_Value_PFW_KKT_boxqp_e3,Final_Value_PFW_KKT_boxqp_e4,
Final_Value_PFWA_KKT_boxqp_e2,Final_Value_PFWA_KKT_boxqp_e3,Final_Value_PFWA_KKT_boxqp_e4,
)

Final_Value_boxqp_PhaseI=hcat(Final_Value_CFW_PhaseI_boxqp_e2,Final_Value_CFW_PhaseI_boxqp_e3,Final_Value_CFW_PhaseI_boxqp_e4,
Final_Value_ASFW_PhaseI_boxqp_e2,Final_Value_ASFW_PhaseI_boxqp_e3,Final_Value_ASFW_PhaseI_boxqp_e4,
Final_Value_ASFWA_PhaseI_boxqp_e2,Final_Value_ASFWA_PhaseI_boxqp_e3,Final_Value_ASFWA_PhaseI_boxqp_e4,
Final_Value_PFW_PhaseI_boxqp_e2,Final_Value_PFW_PhaseI_boxqp_e3,Final_Value_PFW_PhaseI_boxqp_e4,
Final_Value_PFWA_PhaseI_boxqp_e2,Final_Value_PFWA_PhaseI_boxqp_e3,Final_Value_PFWA_PhaseI_boxqp_e4,
)

out1_path="/Users/Mindy/Desktop/NEW/" 
cd(out1_path)

XLSX.openxlsx("All.xlsx", mode="rw") do io
    sh1 = io["Running_Time-Phase I"]
    sh1["F4:T93"]=Final_Value_boxqp_PhaseI
    sh2 = io["Running_Time-KKT"]
    sh2["F4:T93"]=Final_Value_boxqp_KKT
     
end



