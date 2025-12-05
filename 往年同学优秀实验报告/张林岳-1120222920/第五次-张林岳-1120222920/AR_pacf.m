%对序列求自相关函数再作DFT进行谱估计
function [power_of_acf]=pacf(x,num)

%x   : 数据样本(行向量)
%num : 期望的功率谱的点数,num应大于x的长度.
%power_of_acf :功率谱的模.

[~,N]=size(x);
[~,rxx1]=acf(x,N);      %求序列的自相关函数
power_of_acf=abs(fft(rxx1,num));    %对自相关函数作DFT

%翻转
% for i=1:num/2
%   c=power_of_acf(i);
%   power_of_acf(i)=power_of_acf(i+num/2);
%   power_of_acf(i+num/2)=c;
% end

