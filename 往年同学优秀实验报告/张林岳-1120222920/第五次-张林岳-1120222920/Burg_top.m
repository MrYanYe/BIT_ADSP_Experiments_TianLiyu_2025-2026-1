clc;
clear;
close all;
rng('default');
rng(2920);

N = 128;        %数据长度
f1=0.05;
f2=0.40;
f3=0.42;        %信号不同分量的频率
noiseAmp = 0.1; %噪声的幅度
t=0:N-1;
s1 = sin(2*pi*f1*t);
s2 = sin(2*pi*f2*t);
s3 = sin(2*pi*f3*t);
n = randn(1, N) + i * randn(1, N);
n=n*noiseAmp;
A1=1;
A2=1;
A3=1;           %不同频率分量的振幅
s = A1*s1 + A2*s2 + A3*s3 + n;
rtest=conj(s);

%使用Burg法求功率谱
p1=8;
[rj1,~]=pburg(rtest,p1,2^18);
subplot(221);
plot((1:length(rj1))/length(rj1),10*log10(rj1));
xlabel('\omega/2\pi','FontSize',16,'FontWeight','bold');
ylabel('PSD(dB)');
title(['伯格法 IP=',num2str(p1)],'FontSize',16);
grid on;

p2=10;
[rj2,~]=pburg(rtest,p2,2^18);
subplot(222);
plot((1:length(rj2))/length(rj2),10*log10(rj2));
xlabel('\omega/2\pi','FontSize',16,'FontWeight','bold');
ylabel('PSD(dB)');
title(['伯格法 IP=',num2str(p2)],'FontSize',16);
grid on;

p3=16;
[rj3,~]=pburg(rtest,p3,2^18);
subplot(223);
plot((1:length(rj3))/length(rj3),10*log10(rj3));
xlabel('\omega/2\pi','FontSize',16,'FontWeight','bold');
ylabel('PSD(dB)');
title(['伯格法 IP=',num2str(p3)],'FontSize',16);
grid on;

p4=24;
[rj4,~]=pburg(rtest,p4,2^18);
subplot(224);
plot((1:length(rj4))/length(rj4),10*log10(rj4));
xlabel('\omega/2\pi','FontSize',16,'FontWeight','bold');
ylabel('PSD(dB)');
title(['伯格法 IP=',num2str(p4)],'FontSize',16);
grid on;

% for IP=1:N-1
%     [~,var]=pburg(rtest,IP,2^9);
%     var_P(IP)=abs(var);
% end
% plot(var_P);
% xlabel('阶数P','FontSize',16);
% title(['N=',num2str(N),'时，\sigma_\omega ^{2}和阶数P的关系(Burg)'],'FontSize',16);
% xlim([1,N-1]);
