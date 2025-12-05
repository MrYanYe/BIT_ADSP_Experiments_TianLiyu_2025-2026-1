function [power_of_acf]=pacf(x,num)

%function [power_of_acf]=pacf(x,num)
%周期图谱估计方法(验证4.19与4.18等价)
%公式取自<<现代谱估计>> P58 (4.19)
%x   : 数据样本(行向量)
%num : 期望的功率谱的点数,num应大于x的长度.
%power_of_acf :功率谱的模.

[s,N]=size(x);

[rxx,rxx1]=acf(x,N);
power_of_acf=abs( fft(rxx1,num) );

%翻转
for i=1:num/2
  c=power_of_acf(i);
  power_of_acf(i)=power_of_acf(i+num/2);
  power_of_acf(i+num/2)=c;
end

