clc;
clear;
close all;
rng('default');
rng(2920);      %固定随机种子

N =32;             %数据长度
f1=0.05;
f2=0.40;
f3=0.42;    %信号的频率分量
noiseAmp = 0.1;     %噪声的幅度
t=0:N-1;
A1=1;
A2=1;
A3=1;       %各频率分量的幅值
s1 = A1*sin(2*pi*f1*t);
s2 = A2*sin(2*pi*f2*t);
s3 = A3*sin(2*pi*f3*t);
n = randn(1, N) + i*randn(1, N);    %生成噪声
n=n*noiseAmp;
s = s1 + s2 + s3 + n;   %合成信号
rtest = conj(s);

% ra=pper(rtest,2^9);   %直接进行DFT，算出周期图谱估计
% subplot(221);
% plot((1:length(ra))/length(ra),ra);
% xlabel('\omega/2\pi','FontSize',16,'FontWeight','bold');
% title('周期图谱估计','FontSize',16);
% grid on;
% 
% rb=pacf(rtest,2^9);   %由自相关序列进行DFT，算出周期图谱估计
% subplot(223);
% plot((1:length(rb))/length(rb),rb);
% xlabel('\omega/2\pi','FontSize',16,'FontWeight','bold');
% title('由自相关序列算周期图谱估计(两者等价)','FontSize',16);
% grid on;

%直接求自相关矩阵的逆矩阵解Y-W方程
IP1=floor(N/8);     %向下取整
% IP1=10;
[re1,~]=pcorr(rtest,IP1,2^18);
subplot(221)
plot((1:length(re1))/length(re1),re1);
xlabel('\omega/2\pi','FontSize',16,'FontWeight','bold');
title(['自相关法 IP=N/8=',num2str(IP1)],'FontSize',16);
grid on;

IP2=floor(N/3);
% IP2=16;
[re2,~]=pcorr(rtest,IP2,2^18);
subplot(222)
plot((1:length(re2))/length(re2),re2);
xlabel('\omega/2\pi','FontSize',16,'FontWeight','bold');
title(['自相关法 IP=N/3=',num2str(IP2)],'FontSize',16);
grid on;

IP3=N/2;
[re1,~]=pcorr(rtest,IP3,2^18);
subplot(223)
plot((1:length(re1))/length(re1),re1);
xlabel('\omega/2\pi','FontSize',16,'FontWeight','bold');
title(['自相关法 IP=N/2=',num2str(IP3)],'FontSize',16);
grid on;

IP4=floor(7*N/8);
[re2,~]=pcorr(rtest,IP4,2^18);
subplot(224)
plot((1:length(re2))/length(re2),re2);
xlabel('\omega/2\pi','FontSize',16,'FontWeight','bold');
title(['自相关法 IP=7N/8=',num2str(IP4)],'FontSize',16);
grid on;

sgtitle(['N=',num2str(N)],'Fontsize',20);   %添加总标题

% for IP=1:N-1
%     [~,var]=pcorr(rtest,IP,2^9);
%     var_P(IP)=abs(var);   %保存当前阶数对应的sigma^2
% end
% plot(var_P);
% xlabel('阶数P','FontSize',16);
% title(['N=',num2str(N),'时，\sigma_\omega ^{2}和阶数P的关系(AR)'],'FontSize',16);
% xlim([1,N-1]);