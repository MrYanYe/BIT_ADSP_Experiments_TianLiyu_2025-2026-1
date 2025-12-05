%直接对序列DFT进行谱估计
function [power_of_per]=pper(x,num)

%x   : 数据样本(行向量)
%num : 期望的功率谱的点数,num应大于x的长度.
%power_of_per :功率谱的模.

[~,N]=size(x);
ra=abs(fft(x,num));     %作num点DFT
power_of_per=ra.*ra/N;  %计算功率谱

%翻转
% for i=1:num/2
%   c=power_of_per(i);
%   power_of_per(i)=power_of_per(i+num/2);
%   power_of_per(i+num/2)=c;
% end

