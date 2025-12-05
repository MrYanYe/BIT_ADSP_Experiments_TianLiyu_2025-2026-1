function [dat]=gen(f,var,num)

%产生含噪的复正弦波
%f  :含若干频率的向量
%var:噪声方差

[m,n]=size(f);
if m==1
 N=n;
end
if n==1
 N=m;
end

signal=zeros(1,num);
noise=sqrt(var)*randn(1,num);

for i=1:num
for j=1:N
  signal(i)=signal(i)+exp(sqrt(-1)*2*pi*f(j)*i );
end
end

dat=sqrt(2)*signal+noise; %信号幅度sqrt(2),功率1
                          %信噪比=10*log10(1/var)


