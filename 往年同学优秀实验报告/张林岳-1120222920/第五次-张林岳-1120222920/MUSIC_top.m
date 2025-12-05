clc;
clear;
close all;
rng('default');
rng(2920);

f=[0.4,0.42,0.21];  %信号频率向量
A=[1,1,1];          %不同信号的振幅向量
var=0.1;            %噪声方差
N=64;               %序列长度
dat=gen(f,A,var,N); %生成包含噪声的序列

p1=floor(N/8);
rh1=pmusic(f,dat,p1,2^10);
subplot(221);
plot((1:length(rh1))/length(rh1),rh1,'color',[0 0.4470 0.7410]);
xlabel('\omega/2\pi','FontSize',16,'FontWeight','bold');
msg=['MUSIC算法 m=N/8=',num2str(p1),'，噪声方差=',num2str(var)];
title(msg,'FontSize',16);
grid on;

p2=floor(N/3);
rh2=pmusic(f,dat,p2,2^10);
subplot(222);
plot((1:length(rh2))/length(rh2),rh2,'color',[0 0.4470 0.7410]);
xlabel('\omega/2\pi','FontSize',16,'FontWeight','bold');
msg=['MUSIC算法 m=N/3=',num2str(p2),'，噪声方差=',num2str(var)];
title(msg,'FontSize',16);
grid on;

p1=N/2;
rh1=pmusic(f,dat,p1,2^10);
subplot(223);
plot((1:length(rh1))/length(rh1),rh1,'color',[0 0.4470 0.7410]);
xlabel('\omega/2\pi','FontSize',16,'FontWeight','bold');
msg=['MUSIC算法 m=N/2=',num2str(p1),'，噪声方差=',num2str(var)];
title(msg,'FontSize',16);
grid on;

p2=N-1;
rh2=pmusic(f,dat,p2,2^10);
subplot(224);
plot((1:length(rh2))/length(rh2),rh2,'color',[0 0.4470 0.7410]);
xlabel('\omega/2\pi','FontSize',16,'FontWeight','bold');
msg=['MUSIC算法 m=N-1=',num2str(p2),'，噪声方差=',num2str(var)];
title(msg,'FontSize',16);
grid on;

sgtitle(['N=',num2str(N)],'Fontsize',20);