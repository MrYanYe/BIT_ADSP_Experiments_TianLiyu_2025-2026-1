%求自相关矩阵的逆来求功率谱
function [corr,var]=pcorr(x,p,num)

%x   :数据样本行向量
%p   :Ak的阶数
%num :期望的功率谱的点数

[rxx,~]=acf(x,p+1); %求自相关函数
mr = macf(x,p);     %求估计自相关矩阵
ak=-inv(mr)*rxx(2:p+1).';   %rxx(1,2:p+1),去掉rxx(0), 
temp=[1;ak];

var=rxx*temp;       %var即为sigma^2，由Y-W方程第一行表达式得到

p0=fft(temp,num);
p1=p0.*conj(p0);
p2=var./p1;         %由功率谱表达式得到
corr=abs(p2);

%翻转
% for i=1:num/2
%   c=corr(i);
%   corr(i)=corr(i+num/2);
%   corr(i+num/2)=c;
% end




