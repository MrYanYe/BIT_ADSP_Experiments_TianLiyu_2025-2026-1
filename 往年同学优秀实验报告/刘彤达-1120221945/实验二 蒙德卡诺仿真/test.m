clear all
%M=1000 更改仿真次数
M=10
I=0
for i=1:M
    x=pi*rand;
    y=rand
    if y<sin(x)
        I=I+1;
    end 
end
I=(I/M)*pi