clc;
clear;
close all;
rng('default');
rng(2920);

fs=1000;    %采样率
f1=100;     
f2=102;
f3=405;     %信号分量的频率
N=512;      %序列长度
Nfft=512;
SNR=10;     %信噪比
f=0:Nfft-1;
n=0:1/fs:(N-1)/fs;
A1=1;
A2=1;
A3=1;       %不同频率分量的振幅
x=A1*cos(2*pi*f1*n)+A2*cos(2*pi*f2*n)+A3*cos(2*pi*f3*n);    %产生信号
x=awgn(x,SNR);      %添加噪声

X=fft(x,Nfft);
X=X.*conj(X);   %直接作DFR得到功率谱
X=X(1:length(X)/2);
X=abs(X);

subplot(121);
plot((1:length(X))/length(X)/2,10*log10(X/max(X)));
xlabel('归一化频率(\omega/2\pi)','FontWeight','bold','FontSize',16);
ylabel('归一化幅值(dB)');
title('DFT求频谱','FontSize',16);
grid on;

p=250;                    %模型阶数
[ap,E]=Levinson(x,p);     %利用列文森递推求解模型系数
[H,w]=freqz(sqrt(E),[1,ap],N);    %根据系数求出功率谱
Px=abs(H).^2;
fb=w/(2*pi);
Px=Px/max(Px);
Px=10*log10(Px);

subplot(122);
plot(fb,Px);
xlabel('归一化频率(\omega/2\pi)','FontWeight','bold','FontSize',16);
ylabel('归一化幅值(dB)');
title('Levinson求解AR频谱','FontSize',16);
grid on;

% for IP=1:N-1
%     [~,var]=Levinson(x,IP);
%     var_P(IP)=abs(var);
% end
% plot(var_P);
% xlabel('阶数P','FontSize',16);
% title(['N=',num2str(N),'时，\sigma_\omega ^{2}和阶数P的关系(Levinson)'],'FontSize',16);
% xlim([1,N-1]);


%利用列文森递推求解模型系数
function [ap,E]=Levinson(x,p)
 
rx=xcorr(x,'biased');   %求x(n)的自相关函数，与定义的acf函数效果相同
rxm=zeros(1,p+1);
N=length(x);

for i=1:p+1
    rxm(i)=rx(N+i-1);   %索引从1开始，用rxm(1)-rxm(p+1)表示rx(0)-rx(p)
end
 
%当阶次m=1时，先求出a1(1)和ρ1
a=zeros(p,p);           %p阶AR模型在阶次为m时的系数
rho=zeros(1,p);         %前向预测的最小误差功率ρ
a(1,1)=-rxm(2)/rxm(1);  %求出a1(1)
rho(1)=rxm(1)*(1-(a(1,1))^2);
 
%Levinson-Durbin递推
k=zeros(1,p);   %反射系数
k(1)=a(1,1);
for m=2:p
    a(m,m)=-rxm(m+1)/rho(m-1);%不纠结这一步，先往下看
    for i=1:m-1
        a(m,m)=a(m,m)-(a(m-1,i)*rxm(m+1-i))/rho(m-1);   %由递推公式得到
    end
    k(m)=a(m,m);    %求反射系数km(km=am(m)),且|km|<1
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