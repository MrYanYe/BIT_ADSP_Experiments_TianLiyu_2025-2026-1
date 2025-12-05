%产生含噪的复正弦波
function [dat]=gen(f,A,var,num)

%f  :含若干频率的向量
%A  :不同频率分量的振幅
%var:噪声方差

m=length(f);    %复正弦信号的个数

signal=zeros(1,num);
noise=sqrt(var)*randn(1,num);   %噪声方差开根作为噪声的振幅

n=1:num;
for k=1:m
    signal=signal+A(k)*exp(j*2*pi*f(k)*n);  %生成信号成分
end

dat=signal+noise;   %生成包含噪声的序列


