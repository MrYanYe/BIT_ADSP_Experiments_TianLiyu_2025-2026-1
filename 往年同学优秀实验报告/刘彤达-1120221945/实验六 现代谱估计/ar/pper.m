function [power_of_per]=pper(x,num)

%function [power_of_per]=pper(x,num)
%周期图谱估计方法
%公式取自<<现代谱估计>> P48 (4.2)
%x   : 数据样本(行向量)
%num : 期望的功率谱的点数,num应大于x的长度.
%power_of_per :功率谱的模.

[s,N]=size(x);

ra=abs( fft(x,num) );
power_of_per=ra.*ra/N;
%翻转
for i=1:num/2
  c=power_of_per(i);
  power_of_per(i)=power_of_per(i+num/2);
  power_of_per(i+num/2)=c;
end

