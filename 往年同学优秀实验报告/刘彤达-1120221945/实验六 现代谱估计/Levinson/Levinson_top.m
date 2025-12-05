clear all;
close all;

fs=1000;
f1=100;
f2=102;    %更改两个相近频率值 102 101 200
N=500;                           %序列长度
Nfft=512; 
SNR=10;
f=0:Nfft-1;
n=0:1/fs:(N-1)/fs;
rng(3);

x=cos(2*pi*f1*n)+cos(2*pi*f2*n);      %信号产生
x=awgn(x,SNR);
%%计算p阶数与最小预测误差之间的关系图部分代码
% E=zeros(1,400)
% for i=1:400
%     [ap,E(1,i)]=Levinson(x,i); 
% end
% x=1:400
% y=E(1,x);
% plot(x,y);
% title('p与最小预测误差之间的变化图像');
% xlabel('p阶数')
p=10;                    %模型阶数 更改模型阶数为10 100 200 400
[ap,E]=Levinson(x,p);     %利用李文森递推求解模型系数
[H,w]=freqz(sqrt(E),[1,ap],N);    %根据系数求出功率谱
Px=abs(H).^2;fb=w/(2*pi);
Px=Px/max(Px);Px=10*log10(Px);

X=fft(x,Nfft);
X=abs(X);

deltaW=2*pi*1.03/(p*(SNR*(p+1))^0.31);%SNR*p>10时，求AR谱估计频率分辨率的近似公式，不一定正确

figure
plot(fb,Px);
xlabel('归一化频率')
ylabel('归一化幅值(dB)')
title('levinson求解AR频谱')
figure
plot(f,X);
title('DFT求解')


function [ap,E]=Levinson(x,p)
 
rx=xcorr(x,'biased');%求x(n)的自相关函数
rxm=zeros(1,p+1);%索引从1开始，用rxm(1)-rxm(p+1)表示rx(0)-rx(p)
N=length(x);
for i=1:p+1
    rxm(i)=rx(N+i-1);
end
 
%当阶次m=1时，先求出a1(1)和ρ1
a=zeros(p,p);         %p阶AR模型在阶次为m时的系数
rho=zeros(1,p);       %前向预测的最小误差功率ρ
a(1,1)=-rxm(2)/rxm(1);%求出a1(1)
rho(1)=rxm(1)*(1-(a(1,1))^2);
 
%Levinson-Durbin递推
k=zeros(1,p);%反射系数
k(1)=a(1,1);
for m=2:p
    a(m,m)=-rxm(m+1)/rho(m-1);
    for i=1:m-1
        a(m,m)=a(m,m)-(a(m-1,i)*rxm(m+1-i))/rho(m-1);
    end
    k(m)=a(m,m);%求反射系数km(km=am(m)),且|km|<1
    if (k(m)>=1)
        break;
    end
    for i=1:m-1
        a(m,i)=a(m-1,i)+k(m)*a(m-1,m-i);
    end
        rho(m)=rho(m-1)*(1-(k(m))^2);
end
 
%求阶次为p时的系数
ap=zeros(1,p);
for k=1:p
    ap(k)=a(p,k);
end
 
%p阶时最小预测误差功率
E=rho(p);
end